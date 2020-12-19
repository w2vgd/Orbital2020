//
//  MatchingSystemMainPageViewController.swift
//  LinkUs
//
//  Created by macos on 14/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class MatchingSystemMainPageViewController: UIViewController {
    
    
    @IBOutlet weak var viewGuideButton: UIButton!
    
    @IBOutlet weak var enterAsUserButton: UIButton!
    
    @IBOutlet weak var enterAsExpertButton: UIButton!
    
    var user: LoginUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.styleBlueBorderButton(enterAsUserButton)
        Utilities.styleBlueBorderButton(enterAsExpertButton)
        Utilities.styleBlueBorderButton(viewGuideButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
    }
    
    @IBAction func enterAsUserButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func enterAsExpertButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func unwindToMSMainPage(unwindSegue: UIStoryboardSegue) {
    }
    
}
