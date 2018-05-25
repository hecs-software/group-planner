//
//  SuggestionsViewController.swift
//  group-planner
//
//  Created by Hoang on 5/25/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Foundation
import UIKit


class SuggestionsViewController: UIViewController, UICollectionViewDataSource,
                                ProfilePictureCellDelegate, DaySCDelegate {
    
    @IBOutlet weak var calendarDateView: IntervalsCalendarDateView!
    @IBOutlet weak var calendarView: IntervalsCalendarView!
    @IBOutlet weak var profileCarousel: ProfileCarousel!
    @IBOutlet weak var closeModalButton: UIButton!
    
    var users: [User] = [User]()
    var usersIntervalsMap: [String:[Int:[DateInterval]]]?
    var intervalsMap: [Int:[DateInterval]]?
    var hiddenUsers: [String] = [String]()
    var currentWeek: Week?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        setupCloseModalButton()
        setupCarousel()
        loadCalendarView()
        setupCalendarDateView()
    }
    
    
    func setupCloseModalButton() {
//        closeModalButton.backgroundColor = .white
        closeModalButton.cornerRadiusWithShadow(radius: 12)
    }
    
    
    func setupCarousel() {
        profileCarousel.dataSource = self
        
        let layout = profileCarousel.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: 60, height: 60)
        profileCarousel.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    
    func loadCalendarView() {
        if let map = usersIntervalsMap {
            intervalsMap = Algorithms.findGoodTimes(intervals: map, excludeUsers: hiddenUsers)
            calendarView.renderDateIntervals(intervalsMap: intervalsMap!)
        }
    }
    
    
    func setupCalendarDateView() {
        if let currentWeek = currentWeek {
            calendarDateView.setupCurrentWeek(delegate: self, currentWeek: currentWeek)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePictureCell
        cell.user = users[indexPath.row]
        cell.isPlusButton = false
        cell.delegate = self
        cell.inGroupsDetailPage = true
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func clickedOnProfile(userId: String, selected: Bool) {
        if let user = User.current(),
            user.objectId! != userId {
            if selected {
                // Remove the index if it appears in hidden users
                if let ind = hiddenUsers.index(of: userId) {
                    hiddenUsers.remove(at: ind)
                }
            }
            else {
                hiddenUsers.append(userId)
            }
            
            loadCalendarView()
        }
    }
    
    
    func clickedOnPlus() {}
    
    
    func pickedDay(_sender: DaySegmentedControl, day: Int) {
        calendarView.switchToDay(weekday: day)
    }
    
    
    @IBAction func onCloseModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
