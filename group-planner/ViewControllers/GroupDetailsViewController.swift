//
//  GroupDetailsViewController.swift
//  group-planner
//
//  Created by Hoang on 5/13/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class GroupDetailsViewController: UIViewController, UICollectionViewDelegate,
                                UICollectionViewDataSource, DaySCDelegate, CalendarDateViewDelegate,
                                UIScrollViewDelegate, UserSearchControllerDelegate {
    
    @IBOutlet weak var calendarDateView: CalendarDateView!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var profileCarousel: UICollectionView!
    var group: Group?
    
    var users: [User] = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        if let group = group {
            self.navigationItem.title = group.name
        }
        
        setupCalendarDateView()
        setupCarousel()
        setupCalendarView()
    }
    
    
    func setupCalendarDateView() {
        calendarDateView.delegate = self
        calendarDateView.cdvDelegate = self
        calendarDateView.setupContainer()
        calendarDateView.setupCurrentWeek(delegate: self)
        calendarDateView.addLaterWeeks(delegate: self)
        calendarDateView.addOlderWeeks(delegate: self)
    }
    
    
    func setupCarousel() {
        profileCarousel.dataSource = self
        
        let layout = profileCarousel.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: 60, height: 60)
        profileCarousel.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    
    func setupCalendarView() {
        fetchEvents()
    }
    
    
    @objc func fetchEvents(completion: (() -> Void)? = nil) {
        if users.count == 0 {return}
        
        let currentWeek = Week(date: Date.today())
        calendarView.loadEvents(ofUsers: users, week: currentWeek)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePictureCell
        if indexPath.row == 0 {
            cell.profileImageView.image = #imageLiteral(resourceName: "plus_sign")
            cell.isPlusButton = true
        }
        else {
            cell.user = users[indexPath.row - 1]
            cell.isPlusButton = false
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func didSnap(toWeek week: Week, dayPicked: Int) {
        calendarView.currentRenderedDay = dayPicked
        calendarView.currentShownWeek = week
        calendarView.loadEvents(ofUsers: users, week: week)
    }
    
    func pickedDay(_sender: DaySegmentedControl, day: Int) {
        calendarView.switchToDay(weekday: day)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == calendarDateView {
            scrollView.setContentOffset(scrollView.contentOffset, animated: true)
        }
    }
    
    @IBAction func inviteButtonClicked(_ sender: UIBarButtonItem) {
        let sc = UserSearchController()
        self.present(sc, animated: true, completion: nil)
    }
    
    func pickedUsers(users: [User]) {
        // TODO Invite people
        GroupInvitation.inviteUsers(requestees: users,
                                    group: group!, completion:
            { (users, errors) in
                if let errors = errors {
                    print(errors)
                }
                else if let users = users {
                    print(users)
                }
        })
        

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSearchSegue" {
            let userSC = segue.destination as! UserSearchController
            userSC.delegate = self
        }
    }
}
