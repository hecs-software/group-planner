//
//  GroupListViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import Parse
import GoogleSignIn

class GroupListViewController: UIViewController, UITableViewDataSource,
                                UITableViewDelegate, GroupCellDelegate {

    @IBOutlet weak var groupsTableView: UITableView!
    var groups: [Group] = []
    
    
    var needsRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        
        fetchGroups()
        
        setupRefreshControl()
    }
    
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsRefresh),
                                               name: Notification.Name("needsRefresh"), object: nil)
    }
    
    
    @objc func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    
    func setupRefreshControl() {
        let rc = UIRefreshControl()
        groupsTableView.insertSubview(rc, at: 0)
        
        rc.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }
    
    
    @objc func onRefresh(_ rc: UIRefreshControl) {
        self.fetchGroups {
            rc.endRefreshing()
        }
    }
    
    
    @objc func fetchGroups(completion: (() -> Void)? = nil) {
        User.fetchGroups { (groups, error) in
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else if let groups = groups {
                self.groups = groups
                self.groupsTableView.reloadData()
            }
            completion?()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let group = groups[indexPath.row]
        cell.group = group
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupObservers()
        
        if needsRefresh {
            fetchGroups()
        }
        
        User.current()!.executeStartupActions()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupDetailsSegue" {
            let cell = sender as! GroupCell
            let vc = segue.destination as! GroupDetailsViewController
            vc.group = cell.group
            vc.users = cell.users
        }
    }
    
    
    func settingsPressed(sender: GroupCell, group: Group) {
        let currentUser = User.current()
        guard currentUser != nil else {return}
        let alertController = UIAlertController(title: "Settings", message: "Do you want to leave \(group.name)?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Leave Group", style: .default,
                                                handler:
            { (_) in
                currentUser!.leaveGroup(group: group, completion: { (success, error) in
                    if let error = error {
                        self.displayAlert(title: "Error", message: "Error leaving group")
                    }
                    else {
                        self.fetchGroups()
                    }
                })
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default,
                                                handler:
            { (_) in
                self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deinitializing Group List VC")
    }
    
}
