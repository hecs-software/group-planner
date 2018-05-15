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
            parseUser.userNotification?.saveInBackground()
        }
        
        if parseUser.groupsIds == nil {
            parseUser.groupsIds = [String]()
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
    }
    
    
    func givePendingPermissions(completion: GTLRCalendarBooleanResult? = nil) {
        self.userNotification?.fetchIfNeededInBackground(block: { (noti, error) in
            if let error = error {
                completion?(false, [error])
            }
            else if let noti = noti as? UserNotification {
                let users = noti.usersNeedPerms!
                
                GGLAPIClient.shared.givePermission(toUsers: Array(users.values), completion: { (usersIds, errors) in
                    if let errors = errors {
                        completion?(false, errors)
                    }
                    else {
                        for key in usersIds {
                            noti.usersNeedPerms!.removeValue(forKey: key)
                        }
                        noti.saveInBackground()
                        completion?(true, nil)
                    }
                })
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
    
}
