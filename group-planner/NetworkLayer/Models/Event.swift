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
    
    class func parseClassName() -> String {
        return "Event"
    }
    
    static func createNewEvent(completion: PFBooleanResultBlock? = nil) {
        let newEvent = Event()
        newEvent.usersGoing = []
        
        let currentUser = PFUser.current() as? User
        guard currentUser != nil else {return}
        
        newEvent.creator = currentUser!
        newEvent.usersGoing.append(currentUser!)
        
        newEvent.saveInBackground(block: completion)
    }
    
    func updateThumbnail(image: UIImage, completion: PFBooleanResultBlock? = nil) {
        self.thumbnail = ParseUtility.getPFFileFromImage(image)
        self.saveInBackground(block: completion)
    }
}
