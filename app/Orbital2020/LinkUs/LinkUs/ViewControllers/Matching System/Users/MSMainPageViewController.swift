//
//  MatchingSystemMainPageViewController.swift
//  LinkUs
//
//  Created by macos on 29/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

// Matching System User Main Page
class MSMainPageViewController: UIViewController {

    @IBOutlet weak var viewMyApplicationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        Utilities.styleBlueBorderButton(viewMyApplicationsButton)
        
    }
    
    
    @IBAction func unwindToMSUserMainPage(unwindSegue: UIStoryboardSegue) {
    }
    

}
