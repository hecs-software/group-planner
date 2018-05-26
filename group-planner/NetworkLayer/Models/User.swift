//
//  User.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse
import GoogleSignIn
import GoogleAPIClientForREST

class User: PFUser {
    static let oauthType = "google"
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String?
    @NSManaged var profilePicture: PFFile?
    @NSManaged var gglCalendarId: String?
    @NSManaged var groupsIds: [String]?
    @NSManaged var userNotification: UserNotification?
    
    @NSManaged var usersACL: [String:String]?
    
    var name: String {
        get {
            if let lastName = lastName {
                return "\(firstName) \(lastName)"
            }
            else {
                return firstName
            }
        }
    }
    
    
    static func createNewUser(email: String, firstName: String,
                              lastName: String? = nil, profilePicture: UIImage? = nil,
                              completion: PFBooleanResultBlock? = nil) {
        let newUser = User()
        newUser.email = email
        newUser.firstName = firstName
        newUser.lastName = lastName
        
        if let image = profilePicture {
            newUser.profilePicture = ParseUtility.getPFFileFromImage(image)
        }
        
        newUser.signUpInBackground(block: completion)
    }
    
    
    // Format
    // ["id": "user id", "access_token":"google access token"]
    static func oauthLogin(gidUser: GIDGoogleUser, completion: Callback? = nil,
                           uploadCompletion: PFBooleanResultBlock? = nil) {
        let authData: [String:String] = [
            "id": gidUser.userID,
            "access_token": gidUser.authentication.accessToken
        ]
        
        let user = User.logInWithAuthType(inBackground: User.oauthType, authData: authData)
        user.continueOnSuccessWith { (task) -> Any? in
            if let user = task.result as? User {
                GGLAPIClient.shared.setAuthorizer(user: gidUser)
                GGLAPIClient.shared.getPrimaryCalendar(completion: { (ticket, calendar, error) in
                    if let error = error {
                        uploadCompletion?(false, error)
                    }
                    else if let calendar = calendar {
                        User.updateUser(gidUser: gidUser, parseUser: user,
                                        calendar: calendar, completion: uploadCompletion)
                    }
                    else {
                        uploadCompletion?(false, nil)
                    }
                })
                
                completion?()
            }
            return nil
        }
    }
    
    
    static func updateUser(gidUser: GIDGoogleUser, parseUser: User,
                           calendar: GTLRCalendar_CalendarListEntry,
                           completion: PFBooleanResultBlock? = nil) {
        parseUser.email = gidUser.profile.email
        parseUser.firstName = gidUser.profile.givenName
        parseUser.lastName = gidUser.profile.familyName
        parseUser.gglCalendarId = calendar.identifier
        
        if parseUser.userNotification == nil {
            parseUser.userNotification = UserNotification()
            parseUser.userNotification?.usersNeedPerms = [String:User]()
            parseUser.userNotification?.usersNeedRevoked = [String]()
            parseUser.userNotification?.saveInBackground()
        }
        else {
            var needsSave = false
            parseUser.userNotification?.fetchIfNeededInBackground(block: { (object, error) in
                if let error = error {
                    print(error)
                }
                else if let userNoti = object as? UserNotification {
                    if userNoti.usersNeedRevoked == nil {
                        userNoti.usersNeedRevoked = [String]()
                        needsSave = true
                    }
                    if userNoti.usersNeedPerms == nil {
                        userNoti.usersNeedPerms = [String:User]()
                        needsSave = true
                    }
                    if needsSave {
                        userNoti.saveInBackground()
                    }
                }
            })
            
            
        }
        
        if parseUser.groupsIds == nil {
            parseUser.groupsIds = [String]()
        }
        
        if parseUser.usersACL == nil {
            parseUser.usersACL = [String:String]()
        }
        
        let profileUrl = gidUser.profile.imageURL(withDimension: 300)
        if let url = profileUrl {
            NetworkUtility.downloadImage(url: url, completion: { (image, error) in
                if let image = image {
                    if let profile = parseUser.profilePicture {
                        ParseUtility.deletePFFile(file: profile, completion: { (error) in
                            if let error = error {
                                print("ERROR: \(error)")
                            }
                        })
                    }
                    let pffile = ParseUtility.getPFFileFromImage(image)
                    parseUser.profilePicture = pffile
                }
                parseUser.saveInBackground(block: { (success, error) in
                    completion?(success, error)
                })
            })
        }
        else {
            parseUser.saveInBackground(block: { (success, error) in
                completion?(success, error)
            })
        }
    }
    
    
    static func logout(completion: PFUserLogoutResultBlock? = nil) {
        User.logOutInBackground(block: completion)
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    func givePendingPermissions(noti: UserNotification, completion: ((Bool) -> Void)? = nil) {
        let users = noti.usersNeedPerms!
        let usersValues = Array(users.values)
        let ids = usersValues.map({ (user) -> String in
            return user.objectId!
        })
        
        User.fetchUsers(with: ids, completion: { (users, error) in
            if let error = error {
                completion?(false)
            }
            else if let users = users {
                let dgroup = DispatchGroup()
                for user in users {
                    dgroup.enter()
                    GGLAPIClient.shared.givePermission(toUser: user, completion: { (ticket, aclRule, error) in
                        if let error = error {
                            print(error)
                        }
                        else if let aclRule = aclRule {
                            noti.usersNeedPerms?.removeValue(forKey: user.objectId!)
                            self.usersACL![user.objectId!] = aclRule.identifier
                        }
                        dgroup.leave()
                    })
                }
                
                dgroup.notify(queue: .main) {
                    noti.saveInBackground()
                    self.saveInBackground()
                    completion?(true)
                }
            }
        })
    }
    
    
    func revokePendingPermissions(noti: UserNotification, completion: ((Bool) -> Void)? = nil) {
        let users = noti.usersNeedRevoked!
        
        User.fetchUsers(with: users, completion: { (users, error) in
            if let error = error {
                completion?(false)
            }
            else if let users = users {
                let dgroup = DispatchGroup()
                for user in users {
                    let aclId = self.usersACL![user.objectId!]
                    if let aclId = aclId {
                        dgroup.enter()
                        GGLAPIClient.shared.revokePermission(aclIdentifier: aclId, completion: { (success, error) in
                            if let error = error {
                                print(error)
                            }
                            else {
                                let index = noti.usersNeedRevoked?.index(of: user.objectId!)
                                if let index = index {
                                    noti.usersNeedRevoked?.remove(at: index)
                                }
                                
                                self.usersACL!.removeValue(forKey: user.objectId!)
                            }
                            dgroup.leave()
                        })
                    }
                }
                
                dgroup.notify(queue: .main) {
                    noti.saveInBackground()
                    self.saveInBackground()
                    completion?(true)
                }
            }
        })
    }
    
    
    func executeStartupActions(completion: ((Bool) -> Void)? = nil) {
        self.userNotification?.fetchIfNeededInBackground(block: { (noti, error) in
            if let error = error {
                print(error)
                completion?(false)
            }
            else if let noti = noti as? UserNotification {
                self.givePendingPermissions(noti: noti)
                self.revokePendingPermissions(noti: noti)
            }
        })
    }
    
    
    static func findUser(with email: String, completion: @escaping UserBooleanResultBlock) {
        let predicate = NSPredicate(format: "email = \(email)")
        let query = User.query(with: predicate)
        query?.getFirstObjectInBackground(block: { (object, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let user = object as? User {
                completion(user, nil)
            }
        })
    }
    
    
    static func searchUsers(withEmail email: String, completion: @escaping UsersBooleanResultBlock) {
        let email = email.lowercased()
        
        let query = User.query()
        query?.whereKey("email", contains: email)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let users = objects as? [User] {
                // Remove the current logged in user from search result
                let users = users.filter({ (user) -> Bool in
                    if let email = user.email {
                        return email != User.current()!.email
                    }
                    
                    return true
                })
                completion(users, nil)
            }
        })
    }
    
    
    static func searchUsers(withQuery searchText: String, completion: @escaping UsersBooleanResultBlock) {
        let searchText = searchText.lowercased()
        
        let emailQuery = User.query()
        emailQuery?.whereKey("email", matchesRegex: "\(searchText)+", modifiers: "i")
        let firstNameQuery = User.query()
        firstNameQuery?.whereKey("firstName", matchesRegex: "\(searchText)+", modifiers: "i")
        let lastNameQuery = User.query()
        lastNameQuery?.whereKey("lastName", matchesRegex: "\(searchText)+", modifiers: "i")
        
        let query = PFQuery.orQuery(withSubqueries: [emailQuery!, firstNameQuery!, lastNameQuery!])
        query.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let users = objects as? [User] {
                // Remove the current logged in user from search result
                let users = users.filter({ (user) -> Bool in
                    if let email = user.email {
                        return email != User.current()!.email
                    }
                    
                    return true
                })
                completion(users, nil)
            }
        })
    }
    
    
    static func fetchGroups(completion: @escaping GroupsResultBlock) {
        let currentUser = User.current()!
        let query = Group.query()
        query?.addDescendingOrder("createdAt")
        query?.includeKey("groupMembers")
        query?.whereKey("objectId", containedIn: currentUser.groupsIds!)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let groups = objects as? [Group] {
                completion(groups, nil)
            }
        })
    }
    
    
    func appendUsersNeedPermission(user: User, completion: PFBooleanResultBlock? = nil) {
        self.userNotification?.fetchIfNeededInBackground(block: { (noti, error) in
            if let error = error {
                completion?(false, error)
            }
            else if let noti = noti as? UserNotification {
                noti.usersNeedPerms![user.objectId!] = user
                noti.saveInBackground(block: completion)
            }
        })
    }
    
    
    func appendUsersNeedRevoke(user: User, completion: PFBooleanResultBlock? = nil) {
        self.userNotification?.fetchIfNeededInBackground(block: { (noti, error) in
            if let error = error {
                completion?(false, error)
            }
            else if let noti = noti as? UserNotification {
                noti.usersNeedRevoked?.append(user.objectId!)
                noti.saveInBackground(block: completion)
            }
        })
    }
    
    
    static func fetchUsers(with ids: [String], completion: UsersBooleanResultBlock? = nil) {
        let query = User.query()
        query?.whereKey("objectId", containedIn: ids)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion?(nil, error)
            }
            else if let users = objects as? [User] {
                completion?(users, nil)
            }
        })
    }
    
    
    func leaveGroup(group: Group, completion: PFBooleanResultBlock? = nil) {
        group.fetchIfNeededInBackground { (object, error) in
            if let error = error {
                completion?(false, error)
            }
            else if let group = object as? Group {
                // Removing the group from this user's group list
                let i = self.groupsIds?.index(of: group.objectId!)
                guard i != nil else {return}
                self.groupsIds?.remove(at: i!)
                
                // Removing this user from the group
                let index = group.groupMembers.index(where: { (user) -> Bool in
                    return user.objectId! == self.objectId!
                })
                guard index != nil else {return}
                group.groupMembers.remove(at: index!)
                if group.groupMembers.count == 0 {
                    group.deleteInBackground()
                }
                else {
                    group.saveInBackground()
                    
                    // Add this user to the revoked pending list for all users
                    // in this group
                    
                    
                }
                self.saveInBackground(block: completion)
                
                
            }
        }
        
    }
    
}
