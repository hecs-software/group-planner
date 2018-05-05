//
//  GroupListViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import Parse

class GroupListViewController: UIViewController, UITableViewDataSource {

  
    
    
    @IBOutlet weak var groupsTableView: UITableView!
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = User.current()
        if let groupList = user?.groups {
            self.groups = groupList
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
        return cell
    }
    
    
}
