//
//  Group.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

class Group: PFObject, PFSubclassing {
    @NSManaged var creator: User
    @NSManaged var name: String
    @NSManaged var groupMembers: [User]
    @NSManaged var thumbnail: PFFile?
    
    class func parseClassName() -> String {
        return "Group"
    }
    
    static func createNewGroup(groupName name: String? = nil, completion: PFBooleanResultBlock? = nil) {
        let newGroup = Group()
        newGroup.groupMembers = []
        
        let currentUser = PFUser.current() as? User
        guard currentUser != nil else {return}
        
        if let name = name {
            newGroup.name = name
        }
        else {
            newGroup.name = "\(currentUser!.firstName)'s Group"
        }
        newGroup.creator = currentUser!
        newGroup.groupMembers.append(currentUser!)
        
        newGroup.saveInBackground(block: completion)
    }
    
    
    func updateThumbnail(image: UIImage, completion: PFBooleanResultBlock? = nil) {
        self.thumbnail = ParseUtility.getPFFileFromImage(image)
        self.saveInBackground(block: completion)
    }
}
