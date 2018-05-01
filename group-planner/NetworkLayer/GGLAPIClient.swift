//
//  GGLAPIClient.swift
//  group-planner
//
//  Created by Hoang on 4/25/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn

typealias GTLRCalendarEventsResult = (GTLRServiceTicket, [GTLRCalendar_Event]?, Error?) -> Void

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
