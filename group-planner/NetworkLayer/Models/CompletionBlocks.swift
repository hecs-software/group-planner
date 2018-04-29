//
//  CompletionBlocks.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse

typealias UserBooleanResultBlock = (User?, Error?) -> Void
typealias UsersInvitedResultBlock = ([User]?, [Error]?) -> Void
typealias EventInvitationsResultBlock = ([EventInvitation]?, Error?) -> Void
typealias GroupInvitationsResultBlock = ([GroupInvitation]?, Error?) -> Void
typealias Callback = () -> Void

typealias JSONResultBlock = ([String:Any]?, Error?) -> Void
typealias ErrorBlock = (Error?) -> Void