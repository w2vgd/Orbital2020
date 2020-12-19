//
//  HomeTabBarController.swift
//  LinkUs
//
//  Created by macos on 21/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import GoogleSignIn

class HomeTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    
    // Stores the information of the login user (will be assigned a LoginUser in HomeViewController), so that the login user is accessible to all child controllers of this tab bar controller
    var user: LoginUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("in viewdidload of home TBC")
        self.delegate = self
        
    }
    
    
    
    // MARK: - TabBarController Delegate Methods
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
    }
    
    // To disable clicking on a selected tab again returning to rootViewController of the navigation stack
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        return tabBarController.selectedViewController != viewController
        
    }

    
    
    // MARK: - Methods used previously for other purposes
    /*
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        /*
        Original matching system tab will show MSUserNavigationController. When the user clicks on it for the first time, this block of code will run. If the user account type is "User", then the navigation controller at the matching system tab will remain as a MSUserNavigation Controller. But if the user account type is "Expert", it changes the navigation controller at the matching system tab to MSExpertNavigationController.
        */
        if let matchingSystemUserNC = viewController as? MSUserNavigationController {
            print("in didselectvc in tbc")
            /*
            if user!.typeOfUser == "Expert" {
                
                print("setting expert NC")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homePageNC = storyboard.instantiateViewController(identifier: "HomePageNC")
                let expertNC = storyboard.instantiateViewController(identifier: "MSExpertNC")
                let forumVC = storyboard.instantiateViewController(identifier: "ForumVC")
                
                expertNC.tabBarItem.title = "Matching System"
                expertNC.tabBarItem.image = UIImage(systemName: "link")
                
                self.setViewControllers([homePageNC, forumVC, expertNC], animated: false)
                
            }
            */
            // If a "User" taps on Matching System tab, check if should show MSMainPageViewController or ApplicationSentViewController depending on whether user has already submitted an application
            if user!.typeOfUser == "User" {
                print("just supposed")
                if user!.hasApplication {
                    print("calling?")
                    matchingSystemUserNC.performSegue(withIdentifier: "MSNCSegueToApplicationSent", sender: nil)
                    
                    print("segue called through checking hasApplication")
                    return
                }
                /*
                // Query the database for whether there is an application with the currentuser's uid
                print("shouldn't get printed?")
                
                let db = Firestore.firestore()
                let applicationsRef = db.collection("applications")
                
                let query = applicationsRef.whereField("userUid", isEqualTo: user!.uid)
                
                query.getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        print("Error getting documents from query")
                        print(error.localizedDescription)
                    } else {
                        
                        print(querySnapshot!.count)
                        
                        if querySnapshot!.count > 0 {
                            
                            matchingSystemUserNC.performSegue(withIdentifier: "MSNCSegueToApplicationSent", sender: nil)
                            
                            print("segue called through querying database")
                        }
                        
                    }
                    
                }
                */
            }
            
        }
    }
    */
}
