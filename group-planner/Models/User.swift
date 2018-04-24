//
//  User.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

class User: PFUser {
    @NSManaged var email: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String?
    @NSManaged var profilePicture: PFFile?
    
    static func createNewUser(email: String, firstName: String,
                              lastName: String? = nil, profilePicture: UIImage? = nil,
                              completion: PFBooleanResultBlock) {
        let newUser = User()
        newUser.email = email
        newUser.firstName = firstName
        newUser.lastName = lastName
        
        if let image = profilePicture {
            newUser.profilePicture = User.getPFFileFromImage(image)
        }
        
        newUser.signUpInBackground(block: completion)
    }
    
    class func getPFFileFromImage(_ image: UIImage) -> PFFile {
        let imageData = UIImagePNGRepresentation(image)!
        return PFFile(name: "profile.png", data: imageData)!
    }
}
