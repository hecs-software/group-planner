//
//  GroupInvitation.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import ParseUI
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
        query?.includeKey("requester")
        query?.includeKey("requestee")
        query?.includeKey("group")
        query?.addDescendingOrder("createdAt")
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
    
    
    func acceptInvitation(completion: PFBooleanResultBlock? = nil, gglCompletion: GTLRCalendarBooleanResult? = nil) {
        let currentUser = User.current()!
        
        // Get all the members that are not the current user
        group.fetchUsersInGroup(completion: { (users, error) in
            if let users = users {
                // Give permission to all the members in the group
                GGLAPIClient.shared.givePermission(toUsers: users) { (usersIds, errors) in
                    if let errors = errors {
                        print(errors)
                        gglCompletion?(false, errors)
                    }
                    else {
                        // Add current user to the group
                        self.group.groupMembers.append(currentUser)
                        
                        self.group.saveInBackground(block: completion)
                        currentUser.groupsIds!.append(self.group.objectId!)
                        currentUser.saveInBackground()
                        
                        self.deleteInBackground()
                        gglCompletion?(true, nil)
                    }
                }
            }
        })
    }
    
    
    func declineInvitation(completion: PFBooleanResultBlock? = nil) {
        self.deleteInBackground(block: completion)
    }
}

