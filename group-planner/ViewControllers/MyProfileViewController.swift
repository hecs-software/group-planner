//
//  MyProfileViewController.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI
import GoogleAPIClientForREST
import GoogleSignIn

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daySCContainer: DaySCContainer!
    @IBOutlet weak var calendarView: CalendarView!
    
    private let service = GTLRCalendarService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("profileUpdated"),
                                               object: nil, queue: .main)
        { _ in
            self.setUserInfo()
        }
        
        setupDaySC()
        setupDateLabel()
        setupProfileImageView()
        setupGoogleService()
    }
    
    
    func setupDaySC() {
        daySCContainer.restoreToCurrentDate()
    }
    
    
    func setupDateLabel() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .weekday], from: date)
        
        let month = components.month!
        let day = components.day!
        let weekday = components.weekday!
        
        let range = Utility.weekDateRange(weekday: weekday, day: day, month: month)
        let begDate = range.0.0
        let endDate = range.0.1
        let begMonth = range.1.0
        let endMonth = range.1.1
        
        
        if begMonth == endMonth {
            let monthName = Utility.MONTH_MAP[begMonth]!
            let dateString = "\(monthName) \(begDate) - \(endDate)"
            dateLabel.text = dateString
        }
        else {
            let month1 = Utility.MONTH_MAP[begMonth]!
            let month2 = Utility.MONTH_MAP[endMonth]!
            let dateString = "\(month1) \(begDate) - \(month2) \(endDate)"
            dateLabel.text = dateString
        }
        dateLabel.sizeToFit()
    }
    
    
    func setupProfileImageView() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
    }
    
    
    func setUserInfo() {
        let user = User.current()
        if let user = user {
            var name = "\(user.firstName) "
            if let lastName = user.lastName {
                name += lastName
            }
            nameLabel.text = name
            emailLabel.text = user.email
            
            profileImageView.file = user.profilePicture
            profileImageView.loadInBackground()
        }
    }
    
    @IBAction func didLogout(_ sender: UIBarButtonItem) {
        User.logout { (error) in
            if let _ = error {
                self.displayAlert(title: "Error", message: "Could not logout")
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func setupGoogleService() {
        let user = GIDSignIn.sharedInstance().currentUser
        service.authorizer = user?.authentication.fetcherAuthorizer()
    }
    
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Display the start dates and event summaries in the UITextView
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        
        if let error = error {
            displayAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        if let events = response.items, !events.isEmpty {
            for event in events {
                let start = event.start!.dateTime ?? event.start!.date!
                let startString = DateFormatter.localizedString(
                    from: start.date,
                    dateStyle: .short,
                    timeStyle: .short)
                outputText += "\(startString) - \(event.summary!)\n"
            }
        } else {
            outputText = "No upcoming events found."
        }
        print(outputText)
    }
}
