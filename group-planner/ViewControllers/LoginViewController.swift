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
import Pastel

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeCalendar]
    
    @IBOutlet weak var signInText: UILabel!
    @IBOutlet weak var signInButtonView: GIDSignInButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInText.isHidden = true 

        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        signInButtonView = GIDSignInButton()
        
        // Configure Pastel Gradient Background
        let pastelView = PastelView(frame: view.bounds)

        // Custom Duration
        pastelView.animationDuration = 2.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 23/255, green: 234/255, blue: 217/255, alpha: 1.0),
                              UIColor(red: 96/255, green: 120/255, blue: 234/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
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
        let window = UIApplication.shared.keyWindow
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeController")
        
        User.oauthLogin(gidUser: user, completion: {
            self.shadeView(shaded: false)
            GGLAPIClient.shared.setAuthorizer(user: user)
            
            DispatchQueue.main.async {
                window?.rootViewController = vc
            }
        }, uploadCompletion: { (_, _) in
            NotificationCenter.default.post(name: NSNotification.Name("profileUpdated"), object: nil)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
