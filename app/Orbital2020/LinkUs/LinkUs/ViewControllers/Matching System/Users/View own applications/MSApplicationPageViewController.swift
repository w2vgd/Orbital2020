//
//  MSApplicationPageViewController.swift
//  LinkUs
//
//  Created by macos on 15/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class MSApplicationPageViewController: UIViewController {
    
    @IBOutlet weak var matchedExpertNameButton: UIButton!
    
    @IBOutlet weak var applicationStatus: UILabel!
    
    @IBOutlet weak var applicantName: UILabel!
    
    @IBOutlet weak var applicantOccupation: UILabel!
    
    @IBOutlet weak var categoryOfConcern: UILabel!
    
    @IBOutlet weak var applicantDescription: UILabel!
    
    var applicationClicked: MSUserApplication?
    
    @IBOutlet weak var rateExpertButton: UIButton!
    
    var reportFlagButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        applicationStatus.text = "Application Status: " + applicationClicked!.applicationStatus!
        matchedExpertNameButton.setTitle(self.applicationClicked!.matchedExpertFullName, for: .normal)
        applicantName.text = applicationClicked!.userFullName
        applicantOccupation.text = applicationClicked!.occupation!.description
        categoryOfConcern.text = applicationClicked!.category!.description
        applicantDescription.text = applicationClicked!.paragraph
        
        // Allow user to rate expert only after the expert mark the application as completed
        // Allow user to report a matched expert only
        switch applicationClicked!.applicationStatus {
        case "Pending":
            matchedExpertNameButton.isHidden = true
            rateExpertButton.isHidden = true
            
        case "Matched":
            matchedExpertNameButton.isHidden = false
            rateExpertButton.isHidden = true
            
            // Create the report flag button
            let flagImage = UIImage(systemName: "flag")
            reportFlagButton = UIBarButtonItem(image: flagImage, style: .done, target: self, action: #selector(reportFlagButtonTapped))
            
            self.navigationItem.rightBarButtonItem = reportFlagButton
        case "Completed":
            matchedExpertNameButton.isHidden = false
            rateExpertButton.isHidden = false
            
            Utilities.styleBlueBorderButton(rateExpertButton)
            
            // Create the report flag button
            let flagImage = UIImage(systemName: "flag")
            reportFlagButton = UIBarButtonItem(image: flagImage, style: .done, target: self, action: #selector(reportFlagButtonTapped))
            
            self.navigationItem.rightBarButtonItem = reportFlagButton
            
        default:
            print("Something went wrong")
        }
        
        
    }
    
    @objc func reportFlagButtonTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userReportExpertVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.userReportExpertViewController) as! MSUserReportExpertViewController
        
        userReportExpertVC.title = "Report Expert"
        
        // Pass the MSUserApplciation to the next viewcontroller
        userReportExpertVC.applicationClicked = self.applicationClicked
        
        // Push the next viewcontroller onto the navigation stack after everything
        self.navigationController?.pushViewController(userReportExpertVC, animated: true)
        
    }
    
    @IBAction func rateExpertButtonTapped(_ sender: Any) {
        
        // Checks if user has already submitted a review for the expert
        if self.applicationClicked!.hasUserSubmittedReview {
            
            // Creating an alert
            let alert = UIAlertController(title: "Attention!", message: "You have already submitted a review for this expert!", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
            // Show the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let userRateExpertVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.userRateExpertViewController) as! MSUserRateExpertViewController
            
            userRateExpertVC.title = "Rate Expert"
            
            // Pass the MSUserApplciation to the next viewcontroller
            userRateExpertVC.applicationClicked = self.applicationClicked
            
            // Push the next viewcontroller onto the navigation stack after everything
            self.navigationController?.pushViewController(userRateExpertVC, animated: true)
            
        }
        
        
        
    }
    
    
    @IBAction func matchedExpertNameButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewExpertReviewsVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.viewExpertReviewsViewController) as! ViewExpertReviewsViewController
        
        viewExpertReviewsVC.title = "Expert's Reviews"
        
        // Pass the MSUserApplciation to the next viewcontroller
        viewExpertReviewsVC.applicationClicked = self.applicationClicked
        
        // Push the next viewcontroller onto the navigation stack after everything
        self.navigationController?.pushViewController(viewExpertReviewsVC, animated: true)
        
    }
    
}
