//
//  CreateGroupViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/30/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class CreateGroupViewController: UIViewController, UserSearchControllerDelegate {
    
    static let GROUP_NAME_CAP: Int = 25
    
    
    @IBOutlet weak var groupNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var pickedUsers: [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupNameTextField.addTarget(self, action: #selector(cappingTextField), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
        searchTextField.addTarget(self, action: #selector(displaySearchController), for: .editingDidBegin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickDone(_ sender: UIBarButtonItem) {
        Group.createNewGroup(groupName: groupNameTextField.text) { (group, error) in
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else if let group = group {
                GroupInvitation.inviteUsers(requestees: self.pickedUsers,
                                            group: group, completion:
                    { (users, errors) in
                        if let errors = errors {
                            print(errors)
                        }
                        else if let users = users {
                            print(users)
                        }
                })
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("needsRefresh"),
                                                    object: nil)
                })
            }
        }
    }
    
    
    @IBAction func onClickCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func displaySearchController() {
        self.performSegue(withIdentifier: "usersSearchControllerSegue", sender: nil)
    }
    
    func pickedUsers(users: [User]) {
        self.pickedUsers = users
        self.dismiss(animated: true, completion: nil)
        searchTextField.resignFirstResponder()
        
        var names = ""
        for i in 0..<users.count {
            if i == users.count - 1 {
                names += users[i].name
            }
            else {
                names += users[i].name + ", "
            }
        }
        
        searchTextField.text = names
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usersSearchControllerSegue" {
            let userSC = segue.destination as! UserSearchController
            userSC.delegate = self
            
            for user in self.pickedUsers {
                userSC.pickedUsers[user.objectId!] = user
            }
        }
    }
    
    
    @objc func cappingTextField(_ textField: UITextField) {
        if let text = textField.text {
            if text.count > CreateGroupViewController.GROUP_NAME_CAP {
                let endIndex = text.index(text.endIndex, offsetBy: -1)
                textField.text = String(text[..<endIndex])
            }
        }
    }
    
    
    deinit {
        print("Deinitializing create group view controller")
    }

}
