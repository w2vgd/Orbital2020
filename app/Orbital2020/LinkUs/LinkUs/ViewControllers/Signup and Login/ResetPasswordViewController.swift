//
//  ResetPasswordViewController.swift
//  LinkUs
//
//  Created by macos on 6/7/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        Utilities.styleBlackBottomLineTextField(email)
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        
        // Validate the email field
        let error = validateEmail()
        
        if let err = error {
            
            // There is something wrong with the fields
            showError(err)
        }
        else {
            
            let emailAddress = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().sendPasswordReset(withEmail: emailAddress) { [weak self] error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard error == nil else {
                    print("Error sending password reset email")
                    
                    // There was an error sending the password reset email
                    strongSelf.showError("Error sending password reset email: \(error!.localizedDescription)")
                    
                    return
                }
                
                // Successfully sent password reset email
                print("Successfully sent password reset email")
                
                // Creating an alert
                let alert = UIAlertController(title: "Sent", message: "A password reset email has been sent to \(emailAddress). Please check your inbox.", preferredStyle: .alert)
                
                // Add an action to the alert
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: strongSelf.popBackToPreviousViewController))
                
                // Show the alert
                strongSelf.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func popBackToPreviousViewController(alert: UIAlertAction!) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func validateEmail() -> String? {
        
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Utilities.styleRedBottomLineTextField(email)
            return "Please fill in an email!"
        } else {
            Utilities.styleBlackBottomLineTextField(email)
            return nil
        }
    }
    
    func showError(_ message: String) {
        
        // Showing the red alert, (want to  remove and just show the prompt?)
        errorLabel.text = message
        errorLabel.alpha = 1
        
        // Create an alert prompt
        
        // Creating an alert
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        // Add an action to the alert
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
}
