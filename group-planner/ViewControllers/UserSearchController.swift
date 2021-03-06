//
//  UserSearchController.swift
//  group-planner
//
//  Created by Hoang on 5/13/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class UserSearchController: UIViewController, UISearchBarDelegate, UITableViewDelegate,
                            UITableViewDataSource {
    
    static let CONFIRMATION_MESSAGE: String =
    "All group members' calendars will be shared with the invitees once they accept the request"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var invitees: [User] = [User]()
    
    weak var delegate: UserSearchControllerDelegate? = nil
    
    var pickedUsers: [String:User] = [String:User]()
    var excludeUsers: [String] = [String]()
    
    var timer: Timer? = nil
    var searchText: String? = nil
    
    var scrollView: UIScrollView!
    var noUsersMatchedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = User.current() {
            excludeUsers.append(user.objectId!)
        }
        
        setupNoUsersMatchedLabel()
        setupSearchBar()
        setupTableView()
        
        searchText = ""
        searchUsers()
    }
    
    
    func setupNoUsersMatchedLabel() {
        scrollView = UIScrollView(frame: usersTableView.frame)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        
        
        let width: CGFloat = 200
        let height: CGFloat = 100
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        noUsersMatchedLabel = UILabel(frame: frame)
        scrollView.addSubview(noUsersMatchedLabel)
        noUsersMatchedLabel.text = "There are no users with that name 😕"
        noUsersMatchedLabel.font = UIFont.systemFont(ofSize: 24)
        noUsersMatchedLabel.isHidden = true
        noUsersMatchedLabel.numberOfLines = 2
    }
    
    
    func setupTableView() {
        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.allowsMultipleSelection = true
    }
    
    
    func reloadData() {
        if invitees.count == 0 {
            showNoUsersMatchedLabel()
        }
        else {
            showSearchResults()
        }
        usersTableView.reloadData()
    }
    
    
    func showSearchResults() {
        usersTableView.isHidden = false
        noUsersMatchedLabel.isHidden = true
        scrollView.isHidden = true
    }
    
    
    func showNoUsersMatchedLabel() {
        noUsersMatchedLabel.sizeToFit()
        noUsersMatchedLabel.center = scrollView.center
        
        usersTableView.isHidden = true
        noUsersMatchedLabel.isHidden = false
        scrollView.isHidden = false
    }
    
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let user = invitees[indexPath.row]
        cell.user = user
        
        if let _ = pickedUsers[user.objectId!] {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitees.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    @IBAction func onClickedAdd(_ sender: UIBarButtonItem) {
        var users = [User]()
        for (_,value) in pickedUsers {
            users.append(value)
        }
        
        let message = UserSearchController.CONFIRMATION_MESSAGE
        displayYesNoAlert(title: "Confirmation", message: message) { (_) in
            self.delegate?.pickedUsers(users: users)
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func onClickedCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func checkFields() {
        if pickedUsers.count == 0 {
            addButton.isEnabled = false
        }
        else {
            addButton.isEnabled = true
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        // TODO: Strip certain characters
        self.searchText = searchText
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                     selector: #selector(searchUsers),
                                     userInfo: nil, repeats: false)
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultCell
        cell.isSelected = true
        
        let user = cell.user!
        pickedUsers[user.objectId!] = user
        checkFields()
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultCell
        cell.isSelected = false
        
        pickedUsers.removeValue(forKey: cell.user!.objectId!)
        checkFields()
    }
    
    
    @objc func searchUsers() {
        if let text = searchText {
            User.searchUsers(withQuery: text) { (users, error) in
                if let error = error {
                    print(error)
                }
                else if let users = users {
                    let users = users.filter({ (user) -> Bool in
                        return !self.excludeUsers.contains(user.objectId!)
                    })
                    
                    self.invitees = users
                }
                
                self.reloadData()
            }
        }
    }
}


protocol UserSearchControllerDelegate: class {
    func pickedUsers(users: [User])
}
