//
//  CreateGroupViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/30/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UserSearchControllerDelegate {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var pickedUsers: [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.addTarget(self, action: #selector(displaySearchController), for: .editingDidBegin)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSearch(_ sender: UIButton) {

    }
    
    
    @IBAction func didCreate(_ sender: UIButton) {
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

}
