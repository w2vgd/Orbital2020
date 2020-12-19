//
//  SceneDelegate.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        // If user is still logged in, show the home tab bar controller upon launching of the app instead of the app main page
        if Auth.auth().currentUser != nil {
            print("user login before")
            print("Checked that user is not nil from scene delegate")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarController = storyboard.instantiateViewController(identifier: Constants.Storyboard.homeTabBarController) as! HomeTabBarController
            
            
            // If this scene's window is nil, then set a new UIWindow object to it
            window = window ?? UIWindow()
            
            // Set the scene's rootviewcontroller to the home tab bar controller
            window!.rootViewController = homeTabBarController
            
            // Make this scene's window be visible
            window!.makeKeyAndVisible()
            
        } else if GIDSignIn.sharedInstance()?.currentUser != nil {
            
            print("Google user sign in before")
            
        } else {
            
            print("no user login before")
            
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}
