//
//  NotificationViewController.swift
//  group-planner
//
//  Created by Hoang on 5/14/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate,
                                UITableViewDataSource, NotificationCellDelegate {
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var groupInvitations: [GroupInvitation] = [GroupInvitation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        setupTableView()
        setupRefreshControl()
        fetchNotifications()
    }
    
    
    func setupRefreshControl() {
        let rc = UIRefreshControl()
        notificationsTableView.insertSubview(rc, at: 0)
        rc.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
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
                self.notificationsTableView.reloadData()
            }
            completion?()
        }
    }
    
    
    func setupTableView() {
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        let groupInv = groupInvitations[indexPath.row]
        cell.groupInv = groupInv
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInvitations.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    
    func acceptedInvitation(groupInvitation inv: GroupInvitation) {
        print(inv)
        inv.acceptInvitation(completion: { (success, error) in
            NotificationCenter.default.post(name: NSNotification.Name("acceptedGroupInvitation"),
                                            object: nil)
            self.groupInvitations = self.groupInvitations.filter({ (groupInv) -> Bool in
                return groupInv.objectId! != inv.objectId!
            })
            self.notificationsTableView.reloadData()
        })
    }
    
    
    func declinedInvitation(groupInvitation inv: GroupInvitation) {
        inv.declineInvitation { (success, error) in
            if let _ = error {
                self.displayAlert(title: "Error", message: "Error declining invitation")
            }
            else if success {
                self.groupInvitations = self.groupInvitations.filter({ (groupInv) -> Bool in
                    return groupInv.objectId! != inv.objectId!
                })
                self.notificationsTableView.reloadData()
            }
        }
    }
    
}
