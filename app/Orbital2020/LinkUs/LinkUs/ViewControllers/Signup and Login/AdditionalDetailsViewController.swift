//
//  AdditionalDetailsViewController.swift
//  LinkUs
//
//  Created by macos on 31/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class AdditionalDetailsViewController: UIViewController {
    
    // To show a spinning loading sign
    private let spinner: JGProgressHUD = {
        let loadingSpinner = JGProgressHUD(style: .dark)
        loadingSpinner.textLabel.text = "Loading"
        return loadingSpinner
    }()
    
    @IBOutlet weak var dobTextField: UITextField!
    
    @IBOutlet weak var genderField: UISegmentedControl!
    
    @IBOutlet weak var updateButton: UIButton!
    
    var datePicker: UIDatePicker?
    
    var user: LoginUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Disable the update button initially
        updateButton.isEnabled = false
        
        // Create a date picker for the dobTextField
        createDatePicker()
        
        // For dobTextField to call the shouldChangeCharactersInRange delegate method
        dobTextField.delegate = self
        
        Utilities.styleBlueBorderButton(updateButton)
        
    }
    
    func createDatePicker() {
        
        datePicker = UIDatePicker()
        
        // Set the date picker mode to only have date and no time
        datePicker?.datePickerMode = .date
        
        // Set maximum date to current date and minimum date to 100 years before
        datePicker?.minimumDate = Date(timeIntervalSinceNow: -3153600000)
        datePicker?.maximumDate = Date()
        
        // Display the date in the text field at each selection of the date picker
        datePicker?.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        
        // Add a toolbar to the date picker
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.isUserInteractionEnabled = true
        
        // space is to position the done button on the right side
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))

        toolbar.setItems([space, doneButton], animated: true)
        toolbar.sizeToFit()
        
        // Assign date picker to the text field
        dobTextField.inputView = datePicker

        // Assign toolbar
        dobTextField.inputAccessoryView = toolbar
        
    }
    
    @objc func handleDatePicker() {
        
        // Create a date formatter
        let formatter = DateFormatter()
        
        // Set date style to MM/DD/YYYY and no time input
        formatter.dateFormat = "MM/dd/yyyy"
        
        // Assign the date string to dobTextField
        dobTextField.text = formatter.string(from: datePicker!.date)
        
    }
    
    @objc func donePressed() {

        view.endEditing(true)
        checkUpdateButton()
    }
    
    // Enable the update button only after user filled dob field
    func checkUpdateButton() {
        
        if dobTextField.text == "" {
            
            updateButton.isEnabled = false
            
        } else {
            
            updateButton.isEnabled = true
            
        }
        
    }
    
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        // Shows the loading spinner
        spinner.show(in: view)
        
        user!.gender = genderField.titleForSegment(at: genderField.selectedSegmentIndex)!
        user!.dob = dobTextField.text!
        
        let userData: [String: Any] = [
            "firstName" : user!.firstName,
            "lastName" : user!.lastName,
            "email" : user!.email,
            "gender" : user!.gender,
            "dob" : user!.dob,
            "creationDate" : user!.creationDate,
            "uid" : user!.uid,
            "hasApplication" : user!.hasApplication,
            "stopReceiveApplications" : user!.stopReceiveApplications,
            "totalUpvoteCount" : user!.totalUpvoteCount,
            "totalDownvoteCount" : user!.totalDownvoteCount,
            "totalForumPostCount": user!.totalForumPostCount,
            "totalForumReplyCount": user!.totalForumReplyCount,
            "totalReportCount" : user!.totalReportCount,
            "totalRatings": user!.totalRatings,
            "totalReviews": user!.totalReviews
        ]
        
        FirebaseFirestoreManager.shared.uploadNewUser(for: user!.uid, with: userData) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            if success {
                
                // No error in storing data to database
                
                // Data saved successfully to database
                print("Data written successfully to database")
                
                // To dismiss the loading spinner
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                strongSelf.transitionToHome()
                
            } else {
                
                // There is an error saving user data in the database
                // To dismiss the loading spinner
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                // Error in saving data to database
                print("Error saving user data!")
                
            }
            
        }
        
    }
    
    func transitionToHome() {
        
        performSegue(withIdentifier: "additionalDetailsSegueToHome", sender: self)
        
        print("transitioning to home via additional details")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For segue to home TBC
        if let homeTabBarController = segue.destination as? HomeTabBarController {
            
            // Update the user variable in home TBC
            homeTabBarController.user = user
            
        }
        
    }
    
    func showError(_ message: String) {
        
        // Create an alert prompt
        
        // Creating an alert
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        
        // Add an action to the alert
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        
        // Show the alert
        present(alert, animated: true, completion: nil)
        
    }

}


// MARK: - UITextField Delegate Methods

extension AdditionalDetailsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // just return false to disable user typing (only for dobTextField)
        if textField == dobTextField {
            return false
        } else {
            return true
        }
    }
    
}
