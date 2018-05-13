//
//  CreateGroupViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/30/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UITableViewDelegate,
UITableViewDataSource, UISearchBarDelegate {
    
    var invitees: [User] = []
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searchController: UISearchController!
    var tableView: UITableView!
    
    var searchText: String?
    var timer: Timer? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchController()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ResultCell.self, forCellReuseIdentifier: "ResultCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.60).isActive = true
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchTextField.addTarget(self, action: #selector(displaySearchController), for: .editingDidBegin)
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        tableView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSearch(_ sender: UIButton) {

    }
    
    
    @IBAction func didCreate(_ sender: UIButton) {
    }
    
    @objc func displaySearchController(){
        self.present(searchController, animated: true, completion: nil)
        tableView.isHidden = false
    }
    
    
    @objc func searchUsers(_ timer: Timer) {
        if let text = searchText {
            print(text)
            User.searchUsers(withEmail: text) { (users, error) in
                if let error = error {
                    print(error)
                }
                else if let users = users {
                    self.invitees = users
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        cell.user = invitees[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitees.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        searchTextField.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        // TODO: Strip certain characters
        self.searchText = searchText
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(searchUsers), userInfo: nil, repeats: false)
        
    }

}
