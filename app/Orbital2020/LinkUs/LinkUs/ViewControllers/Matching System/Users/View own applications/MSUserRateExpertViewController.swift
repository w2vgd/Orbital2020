//
//  MSUserRateExpertViewController.swift
//  LinkUs
//
//  Created by macos on 15/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class MSUserRateExpertViewController: UIViewController {
    
    @IBOutlet weak var ratingsView: CosmosView!
    
    @IBOutlet weak var feedbackTextView: UITextView!
    
    @IBOutlet weak var confirmSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var applicationClicked: MSUserApplication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Modify the feedbackTextView to look like a UITextField
        feedbackTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 5.0
        
        feedbackTextView.delegate = self
        
        // Set placeholder text for paragraph
        feedbackTextView.text = "Enter feedback for expert here"
        feedbackTextView.textColor = .lightGray
        
        // Disable the confirm button initially
        confirmButton.isEnabled = false
        
        ratingsView.settings.fillMode = .half
        
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
        
        print("confirm button tapped in user rate expert")
        
        var feedback: String
        if feedbackTextView.text != "Enter feedback for expert here" {
            feedback = feedbackTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            feedback = ""
        }
        
        FirebaseFirestoreManager.shared.uploadNewReview(application: applicationClicked!, rating: ratingsView.rating, feedback: feedback) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                print("failed")
                return
            }
            
            print("Successfully uploaded new review")
            
            // pop to previous viewcontroller
            // present alert saying successfully reported user
            // Creating an alert
            let alert = UIAlertController(title: "Submitted", message: "Your review has been successfully submitted!", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: strongSelf.popBackToPreviousViewController))
            
            // Show the alert
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    func popBackToPreviousViewController(alert: UIAlertAction!) {
        
        self.navigationController?.popViewController(animated: true)
        
    }

}


// MARK: - Textview Delegate Methods

extension MSUserRateExpertViewController: UITextViewDelegate {
    
    // To hide placeholder text when user begins editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            
            textView.text = nil
            textView.textColor = .black
            
        }
    }
    
    // To show placeholder text if user did not type anything after editing ends
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = "Enter feedback for expert here"
            textView.textColor = .lightGray
        }
    }
    
}
