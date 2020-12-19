//
//  AppDelegate.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Google Sign-in
        GIDSignIn.sharedInstance().clientID = "834485905415-06t144ee0ap6ofko4fk9b1erclenft5b.apps.googleusercontent.com"
        
        
        
        
        // For debugging purposes, to clear local cache in phone
        Firestore.firestore().clearPersistence { (error) in
            print("cleared persistence")
        }
        
        
        /*
        // For debugging purposes to immediately sign out user upon launching of app if user is still logged in
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out")
        }
        */
        return true
    }
    
    
    
    // MARK: - Firebase Google Sign-in authentication methods
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    // for app to run on iOS 8 and older, not sure if needed
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

