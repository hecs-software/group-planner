//
//  MyProfileViewController.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daySCContainer: DaySCContainer!
    @IBOutlet weak var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("profileUpdated"),
                                               object: nil, queue: .main)
        { _ in
            self.setUserInfo()
        }
        
        setupProfileImageView()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
