//
//  GroupListViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import Parse

class GroupListViewController: UIViewController, UITableViewDataSource,
                                UITableViewDelegate{

    @IBOutlet weak var groupsTableView: UITableView!
    var groups: [Group] = []
    
    
    var needsRefresh: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        
        fetchGroups()
        
        setupObservers()
        setupRefreshControl()
    }
    
    
    func setupObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name("groupCreated"),
                                               object: nil, queue: .main)
        { _ in
            self.fetchGroups()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("acceptedGroupInvitation"),
                                               object: nil, queue: .main)
        { _ in
            self.needsRefresh = true
        }
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
    
    
    func fetchGroups(completion: (() -> Void)? = nil) {
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
        
        if needsRefresh {
            fetchGroups()
        }
        
        User.current()!.givePendingPermissions()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupDetailsSegue" {
            let cell = sender as! GroupCell
            let vc = segue.destination as! GroupDetailsViewController
            vc.group = cell.group
            vc.users = cell.users
        }
    }
    
}
