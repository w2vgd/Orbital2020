//
//  MatchingSystemStep3ViewController.swift
//  LinkUs
//
//  Created by macos on 29/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSStep3ViewController: UIViewController {
    
    @IBOutlet weak var confirm: UISegmentedControl!
    
    var submitButton: UIBarButtonItem!
    
    var applicationForm: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Create the Submit button
        submitButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitButtonTapped))
        
        self.navigationItem.rightBarButtonItem = submitButton
        
        // Disable the submit button initially
        submitButton.isEnabled = false
        
    }
    
    @objc func submitButtonTapped() {
        
        // Send out the application to experts after user has confirmed application submission
        sendApplication()
        
    }
    
    // Enable the submit button only after user click yes to confirm submission
    @IBAction func toggleConfirm(_ sender: Any) {
        
        let newValue = confirm.titleForSegment(at: confirm.selectedSegmentIndex)!
        
        if newValue == "Yes" {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? ApplicationSentViewController {
            
            // Pass the applicationForm to ApplicationSentVC
            destinationVC.applicationForm = self.applicationForm
        }
    }
    
    func sendApplication() {
        
        FirebaseFirestoreManager.shared.sendApplicationToExperts(applicationForm: applicationForm!) { [weak self] result, applicationUid in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let expertsUidList):
                // Update the application form
                strongSelf.applicationForm!.expertsUidList = expertsUidList
                strongSelf.applicationForm!.applicationUid = applicationUid
                
                // Data to store to database
                let data: [String: Any] = [
                    "userUid" : strongSelf.applicationForm!.userUid,
                    "userFullName" : strongSelf.applicationForm!.userFullName,
                    "expertsUid" : strongSelf.applicationForm!.expertsUidList!,
                    "applicationUid" : strongSelf.applicationForm!.applicationUid!,
                    "userCategory" : strongSelf.applicationForm!.category!.description,
                    "userOccupation" : strongSelf.applicationForm!.occupation!.description,
                    "userParagraph" : strongSelf.applicationForm!.paragraph!,
                    "applicationStatus" : "Pending",
                    "hasUserSubmittedReview" : false
                ]
                
                FirebaseFirestoreManager.shared.createNewApplication(userUid: strongSelf.applicationForm!.userUid, applicationUid: strongSelf.applicationForm!.applicationUid!, data: data) { success in
                    
                    guard success else {
                        return
                    }
                    
                    // Perform segue only when everything is done (after application is stored to database successfully
                    strongSelf.performSegue(withIdentifier: "step3SegueToApplicationSent", sender: strongSelf)
                    
                }
                
            case .failure(let error):
                print("Failed to send application to experts: \(error)")
            }
            
        }

    }
    
}
