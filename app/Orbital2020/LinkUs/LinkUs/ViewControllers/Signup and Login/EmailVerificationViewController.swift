//
//  EmailVerificationViewController.swift
//  LinkUs
//
//  Created by macos on 22/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class EmailVerificationViewController: UIViewController {
    
    // To show a spinning loading sign
    private let spinner: JGProgressHUD = {
        let loadingSpinner = JGProgressHUD(style: .dark)
        loadingSpinner.textLabel.text = "Loading"
        return loadingSpinner
    }()
    
    @IBOutlet weak var resendEmailVerificationButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        
        navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "house.fill"), style: .done, target: self, action: #selector(transitionToAppMainPage))
        
        Utilities.styleBlueBorderButton(resendEmailVerificationButton)
        Utilities.styleHollowButton(loginButton)
        
    }
    
    @IBAction func resendEmailVerificationButtonTapped(_ sender: Any) {
        
        guard let currUser = Auth.auth().currentUser else {
            print("user not available in email verificaiton page")
            return
        }
        
        if currUser.isEmailVerified {
            print("Email already verified")
            
            // Create an alert prompt
            
            // Creating an alert
            let alert = UIAlertController(title: "Already Verified", message: "Email has already been verified. Please proceed to login.", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
            // Show the alert
            present(alert, animated: true, completion: nil)
            
        } else {
            print("Email not verified yet")
            
            currUser.sendEmailVerification { [weak self] error in
                guard let strongSelf = self else {
                    return
                }
                
                guard error == nil else {
                    print("Error sending email verification link: \(error!.localizedDescription)")
                    return
                }
                
                // Create an alert prompt
                
                // Creating an alert
                let alert = UIAlertController(title: "Sent!", message: "Email verification link sent. Please verify your email.", preferredStyle: .alert)
                
                // Add an action to the alert
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                
                // Show the alert
                strongSelf.present(alert, animated: true, completion: nil)
                
                // Successfully sent email verification link
                print("Successfully resend email link")
            }
        }
        
    }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
    
        guard let currUser = Auth.auth().currentUser else {
            print("no current user")
            return
        }
        
        // Shows the loading spinner
        //spinner.show(in: view)
        
        currUser.reload(completion: { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error reloading user data from firebase: \(error!.localizedDescription)")
                return
            }
            
            
            if currUser.isEmailVerified {
                
                // Email is verified successfully
                
                // To dismiss the loading spinner
                //DispatchQueue.main.async {
                //    strongSelf.spinner.dismiss()
                //}
                
                // No error in storing data to database
                strongSelf.transitionToHome()
                
            } else {
                print("email not verfied yet")
                
                // Create an alert prompt
                
                // Creating an alert
                let alert = UIAlertController(title: "Not Verified", message: "Email address is not verified. Please verify your email address first.", preferredStyle: .alert)
                
                // Add an action to the alert
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                
                // Show the alert
                strongSelf.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func transitionToHome() {
        
        performSegue(withIdentifier: "emailVerificationSegueToHome", sender: self)
        
    }
    
    @objc func transitionToAppMainPage() {
        
        navigationController?.popToRootViewController(animated: true)
        
    }
    
}
