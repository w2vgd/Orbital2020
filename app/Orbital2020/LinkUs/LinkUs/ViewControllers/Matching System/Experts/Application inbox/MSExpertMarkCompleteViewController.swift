//
//  MSExpertMarkCompleteViewController.swift
//  LinkUs
//
//  Created by macos on 15/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSExpertMarkCompleteViewController: UIViewController {
    
    var user: LoginUser?
    
    @IBOutlet weak var confirmSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var returnToHomeButton: UIBarButtonItem!
    
    var applicationClicked: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        Utilities.styleBlueBorderButton(confirmButton)
        
        // Disable the confirm button initially
        confirmButton.isEnabled = false
        
        // Create the Home button
        returnToHomeButton = UIBarButtonItem(image: UIImage(systemName: "house.fill"), style: .done, target: self, action: #selector(returnToHomeButtonTapped))
        
        self.navigationItem.rightBarButtonItem = returnToHomeButton
        
    }
    
    // Enable the submit button only after expert click yes to confirm match
    @IBAction func toggleConfirm(_ sender: Any) {
        
        let newValue = confirmSegmentedControl.titleForSegment(at: confirmSegmentedControl.selectedSegmentIndex)!
        
        if newValue == "Yes" {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
        
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        
        let expertFullName = user!.firstName + " " + user!.lastName
        
        FirebaseFirestoreManager.shared.markComplete(expertUid: user!.uid, expertFullName: expertFullName, userUid: applicationClicked!.userUid, application: applicationClicked!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            if let navController = strongSelf.navigationController {
                for vc in navController.viewControllers {
                    if vc is MSExpertMainPageViewController {
                        navController.popToViewController(vc, animated: true)
                        break
                    } else if vc is NotificationsViewController {
                        navController.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    @objc func returnToHomeButtonTapped() {
        
        if let navController = self.navigationController {
            for vc in navController.viewControllers {
                if vc is MSExpertMainPageViewController {
                    navController.popToViewController(vc, animated: true)
                    break
                } else if vc is NotificationsViewController {
                    navController.popToViewController(vc, animated: true)
                    break
                }
            }
        }
        
        //performSegue(withIdentifier: "markCompleteUnwindSegueToExpertMainPage", sender: self)
        
    }
    
}
