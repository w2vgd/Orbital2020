//
//  SignUpViewController.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class SignUpViewController: UIViewController {
    
    // To show a spinning loading sign
    private let spinner: JGProgressHUD = {
        let loadingSpinner = JGProgressHUD(style: .dark)
        loadingSpinner.textLabel.text = "Loading"
        return loadingSpinner
    }()
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameRequiredLabel: UILabel!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameRequiredLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailRequiredLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRequiredLabel: UILabel!
    
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var dobRequiredLabel: UILabel!
    
    @IBOutlet weak var genderField: UISegmentedControl!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var datePicker: UIDatePicker?
    
    var user: LoginUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleBlackBottomLineTextField(firstNameTextField)
        Utilities.styleBlackBottomLineTextField(lastNameTextField)
        Utilities.styleBlackBottomLineTextField(emailTextField)
        Utilities.styleBlackBottomLineTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        
        // Create a date picker for the dobTextField
        createDatePicker()
        
        firstNameRequiredLabel.isHidden = true
        lastNameRequiredLabel.isHidden = true
        emailRequiredLabel.isHidden = true
        passwordRequiredLabel.isHidden = true
        dobRequiredLabel.isHidden = true
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        dobTextField.delegate = self
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
        
    }
    
    // To validate the information in all fields
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            firstNameRequiredLabel.isHidden = false
            Utilities.styleRedBottomLineTextField(firstNameTextField)
        } else {
            firstNameRequiredLabel.isHidden = true
            Utilities.styleBlackBottomLineTextField(firstNameTextField)
        }
        
        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            lastNameRequiredLabel.isHidden = false
            Utilities.styleRedBottomLineTextField(lastNameTextField)
        } else {
            lastNameRequiredLabel.isHidden = true
            Utilities.styleBlackBottomLineTextField(lastNameTextField)
        }
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            emailRequiredLabel.isHidden = false
            Utilities.styleRedBottomLineTextField(emailTextField)
        } else {
            emailRequiredLabel.isHidden = true
            Utilities.styleBlackBottomLineTextField(emailTextField)
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            passwordRequiredLabel.isHidden = false
            Utilities.styleRedBottomLineTextField(passwordTextField)
        } else {
            passwordRequiredLabel.isHidden = true
            Utilities.styleBlackBottomLineTextField(passwordTextField)
        }
        
        if dobTextField.text == "" {
            dobRequiredLabel.isHidden = false
            Utilities.styleRedBottomLineTextField(dobTextField)
        } else {
            dobRequiredLabel.isHidden = true
            Utilities.styleBlackBottomLineTextField(dobTextField)
        }
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || dobTextField.text == "" {
            
            return "Please fill in all fields!"
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            
            // Password is not secure enough
            return "Please enter a password with a minimum length of 8 characters, and contains at least one special character and at least one number."
        }
        
        return nil
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if let err = error {
            
            // There is something wrong with the fields
            showError(err)
        }
        else {
            
            // All fields have been filled in
            
            // Shows the loading spinner
            spinner.show(in: view)
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let dob = dobTextField.text!
            let gender = genderField.titleForSegment(at: genderField.selectedSegmentIndex)!
            
            
            // Create the user with Firebase
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, err in
                
                // To prevent memory retention cycle
                guard let strongSelf = self else {
                    return
                }
                
                guard err == nil else {
                    // Error creating user with Firebase
                    
                    // To dismiss the loading spinner
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    
                    // There was an error creating the user in FirebaseAuth
                    strongSelf.showError("Error creating user: \(err!.localizedDescription)")
                    return
                }
                
                guard let currUser = result?.user, !currUser.isEmailVerified else {
                    print("User is already verified or user if not available")
                    return
                }
                
                // Creates a dateformatter to format the date to be stored in a desired string format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let creationDate = dateFormatter.string(from: Date())
                
                // Data to be stored to database
                let data: [String : Any] = [
                    "firstName" : firstName,
                    "lastName" : lastName,
                    "email" : email,
                    "gender" : gender,
                    "dob" : dob,
                    "creationDate" : creationDate,
                    "uid" : currUser.uid,
                    "hasApplication" : false,
                    "stopReceiveApplications" : false,
                    "totalUpvoteCount" : 0,
                    "totalDownvoteCount" : 0,
                    "totalForumPostCount" : 0,
                    "totalForumReplyCount" : 0,
                    "totalReportCount" : 0,
                    "totalRatings" : 0.0,
                    "totalReviews" : 0
                ]
                
                FirebaseFirestoreManager.shared.uploadNewUser(for: currUser.uid, with: data) { success in
                    
                    // To dismiss the loading spinner
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    
                    if success {
                        
                        // No error in storing data to database
                        
                        // Send email verification link to user
                        currUser.sendEmailVerification { (error) in
                            
                            guard error == nil else {
                                print("Error sending email verification link")
                                return
                            }
                            
                            // Successfully sent email verification link
                            print("Successfully sent email link")
                            strongSelf.transitionToEmailVerification()
                            
                        }
                        
                    } else {
                        
                        // There is an error saving user data in the database
                        print("Error saving user data")
                        
                    }
                    
                }
                
            }
        }
    }
    
    func showError(_ message: String) {
        
        // Showing the red alert, (want to  remove and just show the prompt?)
        errorLabel.text = message
        errorLabel.alpha = 1
        
        // Create an alert prompt
        
        // Creating an alert
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        
        // Add an action to the alert
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
    
    func transitionToHome() {
        
        performSegue(withIdentifier: "signUpSegueToHome", sender: self)
        
    }
    
    func transitionToEmailVerification() {
        
        performSegue(withIdentifier: "signUpSegueToEmailVerification", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let homeTabBarController = segue.destination as? HomeTabBarController {
            
            // Update the user variable in home TBC
            homeTabBarController.user = self.user
            
        }
        
    }
    
}


// MARK: - UITextField Delegate Methods

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // just return false to disable user typing (only for dobTextField)
        if textField == dobTextField {
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Switch to the next field when the return key is tapped
        
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
            
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
            
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            
        case passwordTextField:
            dobTextField.becomeFirstResponder()
            
        default:
            break
        }
        
        return true
    }
    
}

