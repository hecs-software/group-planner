//
//  GroupInvitation.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

class GroupInvitation: PFObject, PFSubclassing {
    @NSManaged var requester: User
    @NSManaged var requestee: User
    @NSManaged var group: Group
 
    class func parseClassName() -> String {
        return "GroupInvitation"
    }
    
    static func createGroupInvitation(requester: User, requestee: User, group: Group,
                                      completion: PFBooleanResultBlock? = nil) {
        let newInvitation = GroupInvitation()
        newInvitation.requester = requester
        newInvitation.requestee = requestee
        newInvitation.group = group
        
        newInvitation.saveInBackground(block: completion)
    }
    
    static func inviteUsers(requestees: [User], group: Group, completion: UsersInvitedResultBlock? = nil) {
        let currentUser = PFUser.current() as! User
        var usersInvited = [User]()
        let dispatchGroup = DispatchGroup()
        var errors = [Error]()
        
        for requestee in requestees {
            dispatchGroup.enter()
            GroupInvitation.createGroupInvitation(requester: currentUser,
                                                  requestee: requestee,
                                                  group: group,
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

