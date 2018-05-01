//
//  CreateGroupViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/30/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController {
    
    var invitees: [User] = []
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSearch(_ sender: UIButton) {
        User.findUser(with: searchTextField.text!) { (user, error) in
            if let error = error {
                self.displayAlert(title: "Error Searching for User", message: error.localizedDescription)
            } else if let user = user {
                self.invitees.append(user)
            }
        }
    }
    
    
    @IBAction func didCreate(_ sender: UIButton) {
    }
}
