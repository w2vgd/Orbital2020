//
//  LoginViewController.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
//import FirebaseAuth
import Firebase
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    // To show a spinning loading sign
    private let spinner: JGProgressHUD = {
        let loadingSpinner = JGProgressHUD(style: .dark)
        loadingSpinner.textLabel.text = "Loading"
        return loadingSpinner
    }()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    var user: LoginUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
        
        // Initialize Google Sign-in
        GIDSignIn.sharedInstance()?.delegate = self
        
        // For google sign-in
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Automatically sign in the user
        //GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        // Add code to customize the google sign in button if needed
        
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleBlackBottomLineTextField(emailTextField)
        Utilities.styleBlackBottomLineTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // To validate the information in all fields
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Utilities.styleRedBottomLineTextField(emailTextField)
        } else {
            Utilities.styleBlackBottomLineTextField(emailTextField)
        }
        
        if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Utilities.styleRedBottomLineTextField(passwordTextField)
        } else {
            Utilities.styleBlackBottomLineTextField(passwordTextField)
        }
        
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields!"
        }
        
        return nil
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if let err = error {
            
            // There is something wrong with the fields
            showError(err)
        }
        else {
            
            // Shows the loading spinner
            spinner.show(in: view)
            
            // Create cleaned versions of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the user with Firebase
            Auth.auth().signIn(withEmail: email, password: password) {
                [weak self] result, error in
                
                // To prevent memory retention cycle
                guard let strongSelf = self else {
                    return
                }
                
                // To dismiss the loading spinner
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                guard error == nil, let currUser = result?.user else {
                    // Couldn't sign in
                    strongSelf.showError(error!.localizedDescription)
                    return
                }
                
                // Sign in successful
                
                if currUser.isEmailVerified {
                    
                    print("email is verified, transitioning to home from login")
                    strongSelf.transitionToHome()
                    
                } else {
                    
                    print("Email not verified yet")
                    
                    // Create an alert prompt
                    
                    // Creating an alert
                    let alert = UIAlertController(title: "Not Verified", message: "Your email address is not yet verified. Please verify your email address first.", preferredStyle: .alert)
                    
                    // Add an action to the alert
                    alert.addAction(UIAlertAction(title: "Send verification link", style: .default, handler: { _ in
                        
                        currUser.sendEmailVerification { (error) in
                            guard error == nil else {
                                
                                let alert = UIAlertController(title: "Error", message: "Error sending email verification link. Please try again later.", preferredStyle: .alert)
                                
                                // Add an action to the alert
                                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                                
                                // Show the alert
                                strongSelf.present(alert, animated: true, completion: nil)
                                
                                return
                            }
                            
                            // Successfully sent email verification link
                            print("Successfully sent email link")
                            strongSelf.transitionToEmailVerification()
                            
                        }
                        
                    }))
                    
                    // Add an action to the alert
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    
                    // Show the alert
                    strongSelf.present(alert, animated: true, completion: nil)
                    
                    
                }
            }
        }
        
    }
    
    func showError(_ message: String) {
        
        // Showing the red alert,   might remove and just show the prompt
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
        
        performSegue(withIdentifier: "loginSegueToHome", sender: self)
        
    }
    
    func transitionToAdditionalDetails() {
        
        performSegue(withIdentifier: "loginSegueToAdditionalDetails", sender: self)
        
    }
    
    func transitionToEmailVerification() {
        
        performSegue(withIdentifier: "loginSegueToEmailVerification", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For segue to home TBC
        if let homeTabBarController = segue.destination as? HomeTabBarController {
            
            // Update the user variable in home TBC
            homeTabBarController.user = user
            
        }
        // For segue to additional details (for first time google users)
        else if let additionalDetailsVC = segue.destination as? AdditionalDetailsViewController {
            
            // Update the user variable in additional details VC
            additionalDetailsVC.user = user
            
        }
    }
    
    @IBAction func unwindToLoginViewController(unwindSegue: UIStoryboardSegue) {
    }
    
}


// MARK: - Firebase Google Sign-in Authentication Methods

extension LoginViewController:  GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            return
        }
        
        // Shows the loading spinner
        spinner.show(in: view)
        
        // Perform any operations on signed in user here
        
        //let userId = user.userID
        //let idToken = user.authentication.idToken
        //let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        // Sign in Google user with Firebase
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            
            // To prevent memory retention cycle
            guard let strongSelf = self else {
                return
            }
            
            if error == nil {
                
                print("No error, logging in")
                
                // Google user signed in to Firebase successfully, now check if user is logging in for the first time
                
                // Query the database for whether there is an associated email address with the google user already
                let db = Firestore.firestore()
                let usersRef = db.collection("users")
                
                let query = usersRef.whereField("email", isEqualTo: authResult!.user.email!)
                
                query.getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        print("Error getting documents from query")
                        print(error.localizedDescription)
                    } else {
                        
                        if querySnapshot!.count == 1 {
                            
                            // User has an associated account already
                            
                            // To dismiss the loading spinner
                            DispatchQueue.main.async {
                                strongSelf.spinner.dismiss()
                            }
                            
                            strongSelf.transitionToHome()
                            
                        } else if querySnapshot!.count == 0{
                            
                            // User is a new user
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            let creationDate = dateFormatter.string(from: Date())
                            
                            // Create a LoginUser for the new user
                            strongSelf.user = LoginUser(
                                firstName: givenName ?? "",
                                lastName: familyName ?? "",
                                gender: "",  // to be set at the next VC
                                email: email!,
                                dob: "",    // to be set at the next VC
                                uid: authResult!.user.uid,
                                creationDate: creationDate,
                                hasApplication: false,
                                totalUpvoteCount: 0,
                                totalDownvoteCount: 0,
                                totalForumPostCount: 0,
                                totalForumReplyCount: 0,
                                totalReportCount: 0,
                                totalRatings: 0.0,
                                totalReviews: 0)
                            
                            // Checks if new google user has a profile photo in google account. If there is a photo, then upload it to firebase storage
                            if user.profile.hasImage {
                                guard let url = user.profile.imageURL(withDimension: 128) else {
                                    return
                                }
                                
                                // Creates a task that retrieves the contents of the specified url (the profile image)
                                URLSession.shared
                                    .dataTask(with: url, completionHandler:  { (data, _, _) in
                                        guard let data = data else {
                                            return
                                        }
                                        
                                        let fileName = strongSelf.user!.profilePictureFileName
                                        
                                        FirebaseStorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { (result) in
                                            
                                            switch result {
                                            case .success(let downloadUrl):
                                                
                                                // Remove in the future if not used
                                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                                
                                            case .failure(let error):
                                                print("Storage manager error: \(error)")
                                                
                                            }
                                            
                                            print("Successfully uploaded google photo to storage")
                                            
                                            // To dismiss the loading spinner
                                            DispatchQueue.main.async {
                                                strongSelf.spinner.dismiss()
                                            }
                                            
                                            strongSelf.transitionToAdditionalDetails()
                                            
                                        })
                                    }).resume()
                            } else {
                                
                                // Google user has no profile photo associated with google account
                                
                                // To dismiss the loading spinner
                                DispatchQueue.main.async {
                                    strongSelf.spinner.dismiss()
                                }
                                
                                strongSelf.transitionToAdditionalDetails()
                                
                            }
                            
                            
                        } else {
                            // More than one account associated with email
                            print("Something is wrong")
                        }
                    }
                }
                
            } else {
                // Error with google user signing in to Firebase
                print("Problem signing in google user into firebase")
            }
            
        }   
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        // Perform any operations when the user disconnects from the app here.
        
        print("Google user was disconnected")
    }
    
    
}


// MARK: - UITextField Delegate Methods

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Switch to the next field when the return key is tapped
        
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            
        case passwordTextField:
            loginTapped(loginButton!)
            
        default:
            break
        }
        
        return true
    }
    
}
