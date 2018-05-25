//
//  GGLAPIClient.swift
//  group-planner
//
//  Created by Hoang on 4/25/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn


class GGLAPIClient {
    static let shared = GGLAPIClient.init()
    
    private let service = GTLRCalendarService()
    
    private init() {}
    
    func fetchEvents(minDate: Date, maxDate: Date, completion: GTLRCalendarEventsResult? = nil) {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        
        query.timeMin = GTLRDateTime(date: minDate)
        query.timeMax = GTLRDateTime(date: maxDate)
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let events = response as? GTLRCalendar_Events {
                completion?(ticket, events.items, nil)
            }
        }
    }
    
    
    func fetchEvents(fromCalendarId id: String, minDate: Date, maxDate: Date,
                     completion: GTLRCalendarEventsResult? = nil) {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: id)
        query.timeMin = GTLRDateTime(date: minDate)
        query.timeMax = GTLRDateTime(date: maxDate)
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let events = response as? GTLRCalendar_Events {
                completion?(ticket, events.items, nil)
            }
        }
    }
    
    
    // Completion returns a hash map with key as the user object id and value
    // as the user's events
    func fetchEvents(ofUsers users: [User], minDate: Date, maxDate: Date,
                     completion: GTLRCalendarUsersEventsResult? = nil) {
        var result = [String:[GTLRCalendar_Event]]()
        var errors = [Error]()
        let group = DispatchGroup()
        let currentUser = User.current()!
        
        for user in users {
            if user.email == currentUser.email {
                group.enter()
                fetchEvents(minDate: minDate, maxDate: maxDate) { (ticket, events, error) in
                    if let error = error {
                        errors.append(error)
                    }
                    else if let events = events {
                        result[user.objectId!] = events
                    }
                    group.leave()
                }
            }
            else {
                group.enter()
                fetchEvents(fromCalendarId: user.gglCalendarId!, minDate: minDate, maxDate: maxDate) { (ticket, events, error) in
                    if let error = error {
                        errors.append(error)
                    }
                    else if let events = events {
                        result[user.objectId!] = events
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // Could not load everyone's calendar
            if errors.count > 0 {
                completion?(result, errors)
            }
            else {
                completion?(result, nil)
            }
        }
    }
    
    
    func givePermission(toUser user: User, completion: GTLRCalendarAclResult? = nil) {
        let aclRule = GTLRCalendar_AclRule.init()
        aclRule.role = "reader"
        let scope = GTLRCalendar_AclRule_Scope.init()
        scope.type = "user"
        scope.value = user.gglCalendarId
        aclRule.scope = scope
        
        let currentUser = User.current()!
        let query = GTLRCalendarQuery_AclInsert.query(withObject: aclRule, calendarId: "primary")
        query.additionalURLQueryParameters = [
            "sendNotifications": "false"
        ]
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let aclRule = response as? GTLRCalendar_AclRule {
                completion?(ticket, aclRule, nil)
                
                // Add the current user to the list of users that need
                // calendar permissions
                user.appendUsersNeedPermission(user: currentUser)
            }
            else {
                completion?(ticket, nil, nil)
            }
        }
    }
    
    
    func givePermission(toUsers users: [User], completion: GTLRCalendarKeyErrorResult? = nil) {
        var aclCount: Int = 0
        var errors: [Error] = [Error]()
        var usersIds: [String] = [String]()
        let group = DispatchGroup()
        
        for user in users {
            group.enter()
            givePermission(toUser: user) { (ticket, aclRule, error) in
                if let error = error {
                    errors.append(error)
                }
                else {
                    aclCount += 1
                    usersIds.append(user.objectId!)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.count > 0 || aclCount != users.count {
                completion?(usersIds, errors)
            }
            else {
                completion?(usersIds, nil)
            }
        }
    }
    
    
    func revokePermission(aclIdentifier: String, completion: ((Bool, Error?) -> Void)? = nil) {
        let query = GTLRCalendarQuery_AclDelete.query(withCalendarId: "primary", ruleId: aclIdentifier)
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(false, error)
            }
            else {
                completion?(true, nil)
            }
        }
    }
    
    
    func getCalendarList(completion: GTLRCalendarListResult? = nil) {
        let query = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let calendarList = response as? GTLRCalendar_CalendarList {
                completion?(ticket, calendarList, nil)
            }
        }
    }
    
    
    func getPrimaryCalendar(completion: GTLRCalendarListEntryResult? = nil) {
        getCalendarList { (ticket, list, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let list = list {
                if let items = list.items {
                    for item in items {
                        if let primary = item.primary,
                            primary.boolValue {
                            completion?(ticket, item, nil)
                        }
                    }
                }
            }
            else {
                completion?(ticket, nil, nil)
            }
        }
    }
    
    
    func gidSignOut() {
        GIDSignIn.sharedInstance().signOut()
        service.authorizer = nil
    }
    
    
    func setAuthorizer(user: GIDGoogleUser) {
        service.authorizer = user.authentication.fetcherAuthorizer()
    }
    
    
    func debugOutput(events: [GTLRCalendar_Event]) {
        // Debug output
        // Remove later
        /////////////////////////////
        var outputText = ""
        for event in events {
            let start = event.start!.dateTime ?? event.start!.date!
            let startString = DateFormatter.localizedString(
                from: start.date,
                dateStyle: .short,
                timeStyle: .short)
            outputText += "\(startString) - \(event.summary!)\n"
        }
        print(outputText)
        ////////////////////////////////
    }
}
