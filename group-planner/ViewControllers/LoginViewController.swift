//
//  LoginViewController.swift
//  group-planner
//
//  Created by Christopher Guan on 4/16/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendarReadonly]
    
    //let signInButton = GIDSignInButton()


    @IBOutlet weak var signInText: UILabel!
    @IBOutlet weak var signInButtonView: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().signOut()
        signInText.isHidden = true 

        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        signInButtonView = GIDSignInButton()
    }

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            parseLogin(user: user)
        }
    }
    
    func parseLogin(user: GIDGoogleUser) {
        shadeView(shaded: true)
        User.oauthLogin(gidUser: user, completion: {
            self.shadeView(shaded: false)
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }, uploadCompletion: { (_, _) in
            NotificationCenter.default.post(name: NSNotification.Name("profileUpdated"), object: nil)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
