//
//  AppDelegate.swift
//  group-planner
//
//  Created by Christopher Guan on 3/1/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import Parse
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Google sign-in.
        
        
        // Read the Info.plist file to set the client id for the APIClient
        var infoDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            infoDict = NSDictionary(contentsOfFile: path)
            if let dict = infoDict {
                let clientID = dict.object(forKey: "PARSE_MASTER_KEY") as! String
                let appId = dict.object(forKey: "PARSE_APP_ID") as! String
                let server = dict.object(forKey: "PARSE_SERVER") as! String
                Parse.initialize(with: ParseClientConfiguration(block: { (configuration) in
                    configuration.applicationId = appId
                    configuration.clientKey = clientID
                    configuration.server = server
                }))
                
                let googleClientID = dict.object(forKey: "GOOGLE_CLIENT_ID") as! String
                GIDSignIn.sharedInstance().clientID = googleClientID
            }
        }
        
        User.register(AuthDelegate(), forAuthType: "google")

        return true
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

