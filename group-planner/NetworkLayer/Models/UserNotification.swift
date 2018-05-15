//
//  UserNotification.swift
//  group-planner
//
//  Created by Hoang on 5/14/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse


class UserNotification: PFObject, PFSubclassing {
    
    // Google calendars that need permissions from this user
    @NSManaged var usersNeedPerms: [String:User]?
    
    
    class func parseClassName() -> String {
        return "UserNotification"
    }
    
}
