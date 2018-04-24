//
//  EventInvitation.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

class EventInvitation: PFObject, PFSubclassing {
    @NSManaged var requester: User
    @NSManaged var requestee: User
    @NSManaged var event: Event
    
    class func parseClassName() -> String {
        return "EventInvitation"
    }
    
    static func createEventInvitation(requester: User, requestee: User, event: Event,
                                      completion: PFBooleanResultBlock? = nil) {
        let newInvitation = EventInvitation()
        newInvitation.requester = requester
        newInvitation.requestee = requestee
        newInvitation.event = event
        
        newInvitation.saveInBackground(block: completion)
    }
    
    static func inviteUsers(requestees: [User], event: Event, completion: UsersInvitedResultBlock? = nil) {
        let currentUser = PFUser.current() as! User
        var usersInvited = [User]()
        let dispatchGroup = DispatchGroup()
        var errors = [Error]()
        
        for requestee in requestees {
            dispatchGroup.enter()
            EventInvitation.createEventInvitation(requester: currentUser,
                                                  requestee: requestee,
                                                  event: event,
                                                  completion:
                { (success, error) in
                    if let error = error {
                        errors.append(error)
                    }
                    else {
                        usersInvited.append(requestee)
                    }
                    dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.count == 0 {
                completion?(usersInvited, nil)
            }
            else {
                completion?(usersInvited, errors)
            }
        }
    }
}
