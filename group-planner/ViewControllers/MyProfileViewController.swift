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

class MyProfileViewController: UIViewController, DaySCDelegate,
                                UIScrollViewDelegate, CalendarDateViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var calendarDateView: CalendarDateView!
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
        
        setupCalendarDateView()
        setupProfileImageView()
        setupRefreshControl()
        fetchEvents()
    }
    
    
    func setupRefreshControl() {
        rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(fetchEvents), for: .valueChanged)
        calendarView.insertSubview(rc, at: 0)
    }
    
    
    func setupCalendarDateView() {
        calendarDateView.delegate = self
        calendarDateView.cdvDelegate = self
        calendarDateView.setupContainer()
        calendarDateView.setupCurrentWeek(delegate: self)
        calendarDateView.addLaterWeeks(delegate: self)
        calendarDateView.addOlderWeeks(delegate: self)
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
        let week = Week(date: Date.today())
        calendarView.loadEvents(inWeek: week) { (_, events, error) in
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else if let events = events {
                self.calendarView.renderEvents(events: events)
                
            }
            self.rc.endRefreshing()
        }
    }
    
    
    func pickedDay(_sender: DaySegmentedControl, day: Int) {
        calendarView.switchToDay(weekday: day)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
    
    
    func didSnap(toWeek week: Week, dayPicked: Int) {
        calendarView.currentRenderedDay = dayPicked
        calendarView.currentShownWeek = week
        calendarView.loadEvents(inWeek: week)
    }
}
