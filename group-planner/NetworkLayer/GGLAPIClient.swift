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
    
    private init() {
        let user = GIDSignIn.sharedInstance().currentUser
        service.authorizer = user?.authentication.fetcherAuthorizer()
    }
    
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
    
    
    // Completion returns a hash map with key as the user email and value
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
                        result[user.email!] = events
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
                        result[user.email!] = events
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
        scope.value = user.email
        
        let currentUser = User.current()!
        let query = GTLRCalendarQuery_AclInsert.query(withObject: aclRule, calendarId: currentUser.gglCalendarId!)
        service.executeQuery(query) { (ticket, response, error) in
            if let error = error {
                completion?(ticket, nil, error)
            }
            else if let acl = response as? GTLRCalendar_Acl {
                completion?(ticket, acl, nil)
            }
        }
    }
    
    
    func givePermission(toUsers users: [User], completion: GTLRCalendarBooleanResult? = nil) {
        var aclCount: Int = 0
        var errors: [Error] = [Error]()
        let group = DispatchGroup()
        
        for user in users {
            group.enter()
            givePermission(toUser: user) { (ticket, acl, error) in
                if let error = error {
                    errors.append(error)
                }
                else if let _ = acl {
                    aclCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.count > 0 || aclCount != users.count {
                completion?(false, errors)
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
