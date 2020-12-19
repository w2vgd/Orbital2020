//
//  MSExpertMatchViewController.swift
//  LinkUs
//
//  Created by macos on 2/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSExpertMatchViewController: UIViewController {
    
    
    @IBOutlet weak var confirmSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var user: LoginUser?
    
    var applicationClicked: MSUserApplication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
    }
    
    func setUpElements() {
        
        // Disable the submit button initially
        confirmButton.isEnabled = false
        
        Utilities.styleBlueBorderButton(confirmButton)
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
        
        FirebaseFirestoreManager.shared.confirmMatch(expertUid: user!.uid, expertFullName: expertFullName, userUid: applicationClicked!.userUid, application: applicationClicked!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                print("Failed to confirm match")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let proceedToChatVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertProceedToChatViewController) as! MSExpertProceedToChatViewController
            
            proceedToChatVC.title = "Proceed to Chat"
            proceedToChatVC.applicationClicked = strongSelf.applicationClicked
            
            // Push the next viewcontroller onto the navigation stack after everything is done
            strongSelf.navigationController?.pushViewController(proceedToChatVC, animated: true)
            
        }
    }
    
    
}
