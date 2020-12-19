//
//  MSExpertMainPageViewController.swift
//  LinkUs
//
//  Created by macos on 31/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

// Matching System Expert Main Page
class MSExpertMainPageViewController: UIViewController {
    
    @IBOutlet weak var setUpSpecializationsButton: UIButton!
    
    @IBOutlet weak var stopReceiveApplicationsSwitch: UISwitch!
    
    var inboxButton: UIBarButtonItem!
    
    var user: LoginUser?
    
    var applicationsUidList: [String]?
    var applicationsUidToUserFullNameMap: [String : String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        setUpStopReceiveApplicationsSwitch()
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        // Create the Inbox button
        inboxButton = UIBarButtonItem(title: "Inbox", style: .done, target: self, action: #selector(inboxButtonTapped))
        
        // Set the Inbox button as the right bar button item
        self.navigationItem.rightBarButtonItem = inboxButton
        
        Utilities.styleBlueBorderButton(setUpSpecializationsButton)
        
    }
    
    func setUpStopReceiveApplicationsSwitch() {
        
        if user!.stopReceiveApplications {
            stopReceiveApplicationsSwitch.isOn = true
        } else {
            stopReceiveApplicationsSwitch.isOn = false
        }
        
    }
    
    
    @IBAction func stopReceiveApplicationsSwitchValueChanged(_ sender: Any) {
        
        FirebaseFirestoreManager.shared.updateStopReceivingApplications(for: user!.uid, isSwitchOn: stopReceiveApplicationsSwitch.isOn) { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.user!.stopReceiveApplications = strongSelf.stopReceiveApplicationsSwitch.isOn
            
            // Update the user variable in homeTBC
            if let homeTabBarController = strongSelf.tabBarController as? HomeTabBarController {
                
                homeTabBarController.user = strongSelf.user
                
            }
            
        }
        
    }
    
    
    @objc func inboxButtonTapped() {
        
        self.performSegue(withIdentifier: "MSExpertMainPageSegueToInbox", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? MSExpertSpecializationViewController {
            
            destinationVC.user = self.user
            
        }
        
    }
    
    @IBAction func unwindToMSExpertMainPage(unwindSegue: UIStoryboardSegue) {
        
        
    }
    
}
