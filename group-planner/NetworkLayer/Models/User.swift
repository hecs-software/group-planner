//
//  User.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse
import GoogleSignIn

class User: PFUser {
    static let oauthType = "google"
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String?
    @NSManaged var profilePicture: PFFile?
    
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
                user.email = gidUser.profile.email
                user.firstName = gidUser.profile.givenName
                user.lastName = gidUser.profile.familyName
                let profileUrl = gidUser.profile.imageURL(withDimension: 300)
                if let url = profileUrl {
                    NetworkUtility.downloadImage(url: url, completion: { (image, error) in
                        if let image = image {
                            if let profile = user.profilePicture {
                                ParseUtility.deletePFFile(file: profile, completion: { (error) in
                                    if let error = error {
                                        print("ERROR: \(error)")
                                    }
                                })
                            }
                            let pffile = ParseUtility.getPFFileFromImage(image)
                            user.profilePicture = pffile
                        }
                        user.saveInBackground(block: { (success, error) in
                            uploadCompletion?(success, error)
                        })
                    })
                }
                else {
                    user.saveInBackground(block: { (success, error) in
                        uploadCompletion?(success, error)
                    })
                }
                completion?()
            }
            return nil
        }
    }
    
    
    static func logout(completion: PFUserLogoutResultBlock? = nil) {
        User.logOutInBackground(block: completion)
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
    
}
