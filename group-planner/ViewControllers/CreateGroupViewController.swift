//
//  CreateGroupViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/30/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {

    
    var invitees: [User] = []
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searchBar = UISearchBar()
    var searchController = UISearchController()
    var searchResultsView: UITableView = UITableView()
    var searchActive: Bool = false
    var searchUsers: [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.dimsBackgroundDuringPresentation = true
        
        // This is used for dynamic search results updating while the user types
        // Requires UISearchResultsUpdating delegate
        self.searchController.searchResultsUpdater = self
        
        // Configure the search controller's search bar
        self.searchController.searchBar.placeholder = "Search for a user"
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        
        self.searchResultsView.isHidden = true
        searchResultsView.register(ResultCell.self, forCellReuseIdentifier: "ResultCell")
        
        searchResultsView.delegate = self
        
        searchTextField.addTarget(self, action: #selector(displaySearchController), for: .editingDidBegin)
        
        searchController.view.addSubview(searchResultsView)
        let searchBar = searchController.searchBar
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchResultsView.leftAnchor.constraint(equalTo: searchController.view.leftAnchor).isActive = true
        searchResultsView.rightAnchor.constraint(equalTo: searchController.view.rightAnchor).isActive = true
        searchResultsView.bottomAnchor.constraint(equalTo: searchController.view.bottomAnchor).isActive = true
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
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString: String = searchController.searchBar.text!
        if (searchString != "" && !self.searchActive) {
            loadSearchUsers(searchEmail: searchString)
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Force search if user pushes button
        let searchEmail = searchBar.text
        if (searchEmail != "") {
            loadSearchUsers(searchEmail: searchEmail!)
        }

    }
    
    
    func loadSearchUsers(searchEmail: String) {
        self.searchActive = true
        
        User.searchUsers(withEmail: searchEmail) { (users, error) in
            if let error = error {
                self.displayAlert(title: "User not found. Please check the inputted email.", message: error.localizedDescription)
            } else if let users = users {
                self.searchUsers = users
                self.searchResultsView.reloadData()
                self.updateSearchResultsView()
            }
            
            self.searchActive = false
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear any search criteria
        searchBar.text = ""
        
        // Force reload of table data from normal data source
    }
    
    
    func updateSearchResultsView() {
        if (self.searchController.isActive) {
            self.searchResultsView.isHidden = (self.searchUsers.count > 0)
            // TODO DISPLAY USERS IN TABLE VIEW
        } else {
            // Keep the emptyView hidden or update it to use along with the normal data source
            //self.emptyViewLabel.text = "Empty normal data source text"
            //self.emptyView?.hidden = (self.normalDataSource.count > 0)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUsers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let user = searchUsers[indexPath.row]
        cell.user = user
        return cell
    }
}
