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

class MyProfileViewController: UIViewController, DaySCDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daySCContainer: DaySCContainer!
    @IBOutlet weak var calendarView: CalendarView!
    
    var rc: UIRefreshControl!
    
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
        setupRefreshControl()
        fetchEvents()
    }
    
    
    func setupRefreshControl() {
        rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchEvents), for: .valueChanged)
        calendarView.insertSubview(rc, at: 0)
    }
    
    
    func setupDaySC() {
        daySCContainer.delegate = self
    }
    
    
    func setupDateLabel() {
        let sunday = Date.today().previous(.sunday)
        let saturday = Date.today().next(.saturday)
        
        let calendar = Calendar.current
        let begComponents = calendar.dateComponents([.month, .day, .weekday], from: sunday)
        let endComponents = calendar.dateComponents([.month, .day, .weekday], from: saturday)
        
        let begDate = begComponents.day!
        let endDate = endComponents.day!
        let begMonth = begComponents.month!
        let endMonth = endComponents.month!
        
        
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
        
        updateCalendarViewDate(begDate: sunday, endDate: saturday)
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
    
    
    // Construct a query and get a list of upcoming events from the user calendar
    @objc func fetchEvents() {
        let sunday = Date.today().previous(.sunday)
        let saturday = Date.today().next(.saturday)
        
        GGLAPIClient.shared.fetchEvents(minDate: sunday, maxDate: saturday)
        { (_, events, error) in
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else if let events = events {
                self.calendarView.renderEvents(events: events)
                self.rc.endRefreshing()
            }
        }
    }
    
    
    func pickedDay(_sender: DaySegmentedControl, day: Int) {
        calendarView.switchToDay(weekday: day)
    }
    
    func updateCalendarViewDate(begDate: Date, endDate: Date) {
        calendarView.dateRange.0 = begDate
        calendarView.dateRange.1 = endDate
    }
}
