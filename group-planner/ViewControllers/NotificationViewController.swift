//
//  NotificationViewController.swift
//  group-planner
//
//  Created by Hoang on 5/14/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import GoogleSignIn

class NotificationViewController: UIViewController, UITableViewDelegate,
                                UITableViewDataSource, NotificationCellDelegate {
    static let CONFIRMATION_MESSAGE: String =
    "This will share your calendar with all of the members in %@"
    
    
    
    @IBOutlet weak var notificationsTableView: UITableView!

    
    var groupInvitations: [GroupInvitation] = [GroupInvitation]()
    
    var scrollView: UIScrollView!
    var noNotiLabel: UILabel!
    var rcHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        setupTableView()
        setupNoNotiLabel()
        setupRefreshControl()
        fetchNotifications()
    }
    
    
    func setupRefreshControl() {
        let rc = UIRefreshControl()
        notificationsTableView.insertSubview(rc, at: 0)
        rc.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }
    
    
    func setupNoNotiLabel() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        let rc = UIRefreshControl()
        scrollView.insertSubview(rc, at: 0)
        rc.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        rcHeight = rc.frame.height
        
        
        let width: CGFloat = 200
        let height: CGFloat = 50
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        noNotiLabel = UILabel(frame: frame)
        scrollView.addSubview(noNotiLabel)
        noNotiLabel.text = "You have no notifications"
        noNotiLabel.font = UIFont.systemFont(ofSize: 24)
        noNotiLabel.isHidden = true
    }
    
    
    @objc func onRefresh(_ rc: UIRefreshControl) {
        fetchNotifications {
            rc.endRefreshing()
        }
    }
    
    
    func fetchNotifications(completion: (() -> Void)? = nil) {
        GroupInvitation.fetchGroupInvitations { (groupInvs, error) in
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else if let groupInvs = groupInvs {
                self.groupInvitations = groupInvs
                self.reloadData()
            }
            completion?()
        }
    }
    
    
    func showNoNotificationMessage() {
        noNotiLabel.sizeToFit()
        let center = scrollView.center
        let notiLabelCenter = CGPoint(x: center.x, y: center.y - rcHeight)
        noNotiLabel.center = notiLabelCenter
        
        notificationsTableView.isHidden = true
        scrollView.isHidden = false
        noNotiLabel.isHidden = false
    }
    
    
    func showNotiTableView() {
        notificationsTableView.isHidden = false
        noNotiLabel.isHidden = true
        scrollView.isHidden = true
    }
    
    
    func setupTableView() {
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    
    func reloadData() {
        if self.groupInvitations.count > 0 {
            showNotiTableView()
        }
        else {
            showNoNotificationMessage()
        }
        self.notificationsTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        let groupInv = groupInvitations[indexPath.row]
        cell.groupInv = groupInv
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInvitations.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func acceptedInvitation(sender: NotificationCell, groupInvitation inv: GroupInvitation) {
        let message = String.init(format: NotificationViewController.CONFIRMATION_MESSAGE,
                                  inv.group.name)
        displayYesNoAlert(title: "Confirmation", message: message,
                          yesAction:
            { _ in
                sender.acceptIndicator.startAnimating()
                inv.acceptInvitation(completion: { (success, error) in
                    if success {
                        self.groupInvitations = self.groupInvitations.filter({ (groupInv) -> Bool in
                            return groupInv.objectId! != inv.objectId!
                        })
                        self.reloadData()
                    }
                    sender.acceptIndicator.stopAnimating()
                }, gglCompletion: { (success, error) in
                    if !success {
                        self.displayAlert(title: "Error", message: "There was an error in sharing your google calendar")
                    }
                    sender.acceptIndicator.stopAnimating()
                })
                
        })
    }
    
    
    func declinedInvitation(sender: NotificationCell, groupInvitation inv: GroupInvitation) {
        sender.declineIndicator.startAnimating()
        inv.declineInvitation { (success, error) in
            if let _ = error {
                self.displayAlert(title: "Error", message: "Error declining invitation")
            }
            else if success {
                self.groupInvitations = self.groupInvitations.filter({ (groupInv) -> Bool in
                    return groupInv.objectId! != inv.objectId!
                })
                self.reloadData()
            }
            sender.declineIndicator.stopAnimating()
        }
    }
    
}
