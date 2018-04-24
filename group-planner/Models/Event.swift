//
//  Event.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

class Event: PFObject, PFSubclassing {
    @NSManaged var creator: User
    @NSManaged var eventTime: String
    @NSManaged var usersGoing: [User]
    @NSManaged var thumbnail: PFFile?
    
    
}
