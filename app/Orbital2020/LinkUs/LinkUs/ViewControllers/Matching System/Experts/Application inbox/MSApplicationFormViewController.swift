//
//  MSExpertApplicationFormViewController.swift
//  LinkUs
//
//  Created by macos on 2/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSApplicationFormViewController: UIViewController {

    @IBOutlet weak var applicantName: UILabel!
    
    @IBOutlet weak var applicantOccupation: UILabel!
    
    @IBOutlet weak var categoryOfConcern: UILabel!
    
    @IBOutlet weak var applicantDescription: UILabel!
    
    @IBOutlet weak var matchButton: UIButton!
    
    var user: LoginUser?
    
    // Add a report button on the rightbarbuttonitem
    var reportFlagButton: UIBarButtonItem?
    
    var applicationClicked: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
    }
    
    func setUpElements() {
        
        applicantName.text = applicationClicked!.userFullName
        applicantOccupation.text = applicationClicked!.occupation!.description
        categoryOfConcern.text = applicationClicked!.category!.description
        applicantDescription.text = applicationClicked!.paragraph
        
        
        // Create the report flag button
        let flagImage = UIImage(systemName: "flag")
        reportFlagButton = UIBarButtonItem(image: flagImage, style: .done, target: self, action: #selector(reportFlagButtonTapped))
        
        self.navigationItem.rightBarButtonItem = reportFlagButton
        
        Utilities.styleBlueBorderButton(matchButton)
    }
    
    
    @objc func reportFlagButtonTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let expertReportUserVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertReportUserViewController) as! MSExpertReportUserViewController
        
        expertReportUserVC.title = "Report User"
        
        // Pass the MSUserApplciation to the next viewcontroller
        expertReportUserVC.applicationClicked = self.applicationClicked
        
        // Push the next viewcontroller onto the navigation stack after everything
        self.navigationController?.pushViewController(expertReportUserVC, animated: true)
        
    }
    
    
    @IBAction func matchButtonTapped(_ sender: Any) {
        
        // Check if expert has already been matched with user. If already matched, then go straight to proceedToChatVC instead of matchVC
        
        switch applicationClicked!.applicationStatus! {
        case "Pending":
            // Not matched yet
            print("not matched with user yet")
            // Create a new MSExpertMatchViewController when the expert clicks to view an application form
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let matchVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertMatchViewController) as! MSExpertMatchViewController
            
            matchVC.title = "Confirm"
            
            // Pass the MSUserApplciation to the next viewcontroller
            matchVC.applicationClicked = self.applicationClicked
            
            // Push matchviewcontroller onto the navigation stack
            self.navigationController?.pushViewController(matchVC, animated: true)
            
        case "Matched":
            // Matched already
            print("already matched with user")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let proceedToChatVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertProceedToChatViewController) as! MSExpertProceedToChatViewController
            
            proceedToChatVC.title = "Proceed to Chat"
            
            // Pass the MSUserApplciation to the next viewcontroller
            proceedToChatVC.applicationClicked = self.applicationClicked
            
            // Push proceedtochatviewcontroller onto the navigation stack
            self.navigationController?.pushViewController(proceedToChatVC, animated: true)
            
        case "Completed":
            
            // Creating an alert
            let alert = UIAlertController(title: "Access Denied", message: "This application has already been marked as completed!", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
            // Show the alert
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
        
    }
    
}
