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
    @NSManaged var groupMembers: [User]
    @NSManaged var thumbnail: PFFile?
    
    
}
