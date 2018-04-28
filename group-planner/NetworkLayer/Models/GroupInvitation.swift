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
        let currentUser = User.current()!
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
    
    static func fetchGroupInvitations(completion: @escaping GroupInvitationsResultBlock) {
        let currentUser = User.current()!
        let query = GroupInvitation.query()
        query?.whereKey("requestee", equalTo: currentUser)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let error = error {
                completion(nil, error)
            }
            else if let invitations = objects as? [GroupInvitation] {
                completion(invitations, nil)
            }
        })
    }
    
    func acceptInvitation(completion: PFBooleanResultBlock? = nil) {
        let currentUser = User.current()!
        
        // Add current user to the group
        self.group.groupMembers.append(currentUser)
        self.group.saveInBackground(block: completion)
        
        self.deleteInBackground()
    }
}

