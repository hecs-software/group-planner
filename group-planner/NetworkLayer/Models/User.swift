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
    @NSManaged var groups: [Group]?
    
    // Google calendars that need permissions from this user
    @NSManaged var usersNeedPerms: [String:User]?
    
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
        newUser.usersNeedPerms = [String:User]()
        
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
        
        if parseUser.usersNeedPerms == nil {
            parseUser.usersNeedPerms = [String:User]()
        }
        
        if parseUser.groups == nil {
            parseUser.groups = [Group]()
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
        let users = self.usersNeedPerms!
        var errors = [Error]()
        let group = DispatchGroup()
        
        for (key, user) in users {
            group.enter()
            GGLAPIClient.shared.givePermission(toUser: user) { (ticket, acl, error) in
                if let error = error {
                    errors.append(error)
                }
                else {
                    self.usersNeedPerms!.removeValue(forKey: key)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.saveInBackground()
            if errors.count > 0 {
                completion?(false, errors)
            }
            else {
                completion?(true, nil)
            }
        }
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
    
    
    static func searchUsers(with email: String, completion: @escaping UsersBooleanResultBlock) {
        let query = User.query()
        query?.whereKey("email", contains: email)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let users = objects as? [User] {
                completion(users, nil)
            }
        })
    }
    
}
