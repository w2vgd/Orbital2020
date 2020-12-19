//
//  MatchingSystemStep4ViewController.swift
//  LinkUs
//
//  Created by macos on 29/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ApplicationSentViewController: UIViewController {
    
    @IBOutlet weak var applicationSentOutLabel: UILabel!
    
    var applicationForm: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements() {
        
        // Hides the back button back to step3
        self.navigationItem.hidesBackButton = true
        
        
    }
}
