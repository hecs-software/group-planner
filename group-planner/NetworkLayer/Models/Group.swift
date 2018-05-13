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
        
        
        newGroup.saveInBackground { (success, error) in
            currentUser!.groupsIds!.append(newGroup.objectId!)
            currentUser!.saveInBackground()
            completion?(success, error)
        }
    }
    
    
    func updateThumbnail(image: UIImage, completion: PFBooleanResultBlock? = nil) {
        self.thumbnail = ParseUtility.getPFFileFromImage(image)
        self.saveInBackground(block: completion)
    }
    
    func fetchUsersInGroup(completion: @escaping UsersBooleanResultBlock) {
        let ids = self.groupMembers.map {$0.objectId!}
        
        let query = User.query()
        query?.whereKey("objectId", containedIn: ids)
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
