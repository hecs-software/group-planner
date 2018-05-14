//
//  CompletionBlocks.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse
import GoogleAPIClientForREST

typealias UserBooleanResultBlock = (User?, Error?) -> Void
typealias UsersBooleanResultBlock = ([User]?, Error?) -> Void
typealias UsersInvitedResultBlock = ([User]?, [Error]?) -> Void
typealias EventInvitationsResultBlock = ([EventInvitation]?, Error?) -> Void
typealias GroupInvitationsResultBlock = ([GroupInvitation]?, Error?) -> Void
typealias GroupResultBlock = (Group?, Error?) -> Void
typealias GroupsResultBlock = ([Group]?, Error?) -> Void
typealias Callback = () -> Void

typealias JSONResultBlock = ([String:Any]?, Error?) -> Void
typealias ErrorBlock = (Error?) -> Void


// Google API Completion Blocks
typealias GTLRCalendarEventsResult = (GTLRServiceTicket, [GTLRCalendar_Event]?, Error?) -> Void
typealias GTLRCalendarUsersEventsResult = ([String:[GTLRCalendar_Event]]?, [Error]?) -> Void
typealias GTLRCalendarListResult = (GTLRServiceTicket, GTLRCalendar_CalendarList?, Error?) -> Void
typealias GTLRCalendarListEntryResult = (GTLRServiceTicket, GTLRCalendar_CalendarListEntry?, Error?) -> Void
typealias GTLRCalendarAclResult = (GTLRServiceTicket, GTLRCalendar_Acl?, Error?) -> Void
typealias GTLRCalendarErrorResult = (GTLRServiceTicket, Error?) -> Void
typealias GTLRCalendarBooleanResult = (Bool, [Error]?) -> Void
