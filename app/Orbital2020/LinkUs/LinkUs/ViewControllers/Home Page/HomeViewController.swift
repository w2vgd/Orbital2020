//
//  HomeViewController.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SideMenu
import Cosmos

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var userBio: UILabel!
    
    @IBOutlet weak var userFavHobby: UILabel!
    
    @IBOutlet weak var userOccupation: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var upvoteCount: UILabel!
    
    @IBOutlet weak var downvoteCount: UILabel!
    
    @IBOutlet weak var reportCount: UILabel!
    
    @IBOutlet weak var ratingsView: CosmosView!
    
    @IBOutlet weak var totalRatingsCount: UILabel!
    
    @IBOutlet weak var viewBadgesButton: UIButton!
    
    
    // The current login user
    var user: LoginUser?
    
    var userListener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Side menu implemented using storyboards
        
        // Uncomment to  enable swiping left/right to access the menu
        //SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpUserListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        userListener!.remove()
        print("user listener removed in viewdiddisappear")
        
    }
    
    deinit {
           userListener?.remove()
           print("deinit of homeviewcontroller called")
    }
    
    func setUpElements() {
        
        // Style the 2 buttons
        Utilities.styleViewBadgesButton(viewBadgesButton)
        Utilities.styleBlueBorderButton(signOutButton)
        
        // Setting up user profile image
        
        // To make the imageview circular with a border
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2.0
        
        loadProfileImage()
    }
    
    func setUpUserListener() {
        // Gets the current logged in user
        guard let currUser = Auth.auth().currentUser else {
            return
        }
        
        print("setting up user listener")
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currUser.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the user will be updated in realtime when his/her profile has any changes (realtime listener is better than fetching data everytime there is a change)
        userListener = userDocRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            // Using weak self to prevent memory retention cycles
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                if let error = error {
                    print("Error listening to user updates: \(error.localizedDescription)")
                }
                return
            }
            print("user listener method called")
            let data = snapshot.data()!
            
            // Gets the latest information of the user from the database
            strongSelf.user = LoginUser(
                            firstName: data["firstName"] as! String,
                            lastName: data["lastName"] as! String,
                            gender: data["gender"] as! String,
                            email: data["email"] as! String,
                            dob: data["dob"] as! String,
                            uid: data["uid"] as! String,
                            creationDate: data["creationDate"] as! String,
                            favHobby: data["favHobby"] as? String,
                            occupation: data["occupation"] as? String,
                            bio: data["bio"] as? String,
                            hasApplication: data["hasApplication"] as! Bool,
                            specializations: data["specializations"] as? [String],
                            applicationsUidList: data["applicationsUidList"] as? [String],
                            stopReceiveApplications: data["stopReceiveApplications"] as! Bool,
                            totalUpvoteCount: data["totalUpvoteCount"] as! Int,
                            totalDownvoteCount: data["totalDownvoteCount"] as! Int,
                            totalForumPostCount: data["totalForumPostCount"] as! Int,
                            totalForumReplyCount: data["totalForumReplyCount"] as! Int,
                            totalReportCount: data["totalReportCount"] as! Int,
                            totalRatings: data["totalRatings"] as! Double,
                            totalReviews: data["totalReviews"] as! Int)
            
            
            // Update user variable in home TBC
            if let homeTabBarController = strongSelf.tabBarController as? HomeTabBarController {
                
                homeTabBarController.user = strongSelf.user
                
            }
            
            // Set up the profile page with the updated information again
            strongSelf.setUpUserProfilePage()
            
        }
        
    }
    
    func setUpUserProfilePage() {
        
        // Setting up labels
        let placeholderText = "Please update your information!"
        
        userFullName.text = user!.firstName + " " + user!.lastName
        
        userFavHobby.text = user!.favHobby ?? placeholderText
        if userFavHobby.text == placeholderText {
            userFavHobby.textColor = .lightGray
        } else {
            userFavHobby.textColor = .darkText
        }
        
        userOccupation.text = user!.occupation ?? placeholderText
        if userOccupation.text == placeholderText {
            userOccupation.textColor = .lightGray
        } else {
            userOccupation.textColor = .darkText
        }
        
        userBio.text = user!.bio ?? placeholderText
        if userBio.text == placeholderText {
            userBio.textColor = .lightGray
        } else if userBio.text == "A short description about yourself" {
            userBio.text = placeholderText
            userBio.textColor = .lightGray
        } else {
            userBio.textColor = .darkText
        }
        
        upvoteCount.text = "\(user!.totalUpvoteCount)"
        downvoteCount.text = "\(user!.totalDownvoteCount)"
        reportCount.text = "\(user!.totalReportCount)"
        
        totalRatingsCount.text = "(\(user!.totalReviews) total ratings)"
        
        ratingsView.settings.fillMode = .half
        ratingsView.settings.updateOnTouch = false
        ratingsView.settings.textColor = .darkText
        ratingsView.settings.textMargin = 10
        ratingsView.rating = user!.totalReviews == 0 ? 0.0 : user!.totalRatings / Double(user!.totalReviews)
        ratingsView.text = String(format: "%.2f", ratingsView.rating) + " stars"
        
        print("Done setting up user profile page")
        
    }
    
    func loadProfileImage() {
        
        // Gets the current logged in user
        guard let currUser = Auth.auth().currentUser else {
            return
        }
        
        // User's profile image path (if it exist)
        let path = "images/\(currUser.uid)_profile_picture.png"
        
        /* Might need to fix because this keeps downloading url from firebase */
        // Get the url for the user's profile image from Firebase Storage
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self] result in
            print("fetching photo url from storage")
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                // Successfully gotten photo url from storage, now download the photo from the url and display it
                strongSelf.profilePhoto.sd_setImage(with: url, completed: nil)
                
            case .failure(let error):
                
                // Failed to get photo url from storage (mainly due to user not having a profile photo in the first place)
                print("failed to get download url: \(error)")
                
                // Just show the default person.circle image
                strongSelf.profilePhoto.image = UIImage(systemName: "person.circle")
            }
        }
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        
        // Create an action sheet prompt to let user confirm to logout
        
        // Creating an actionsheet
        let actionSheet = UIAlertController(title: "Confirm to Logout",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        // Add an action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _  in
            // Using weak self to prevent memory retention cycles
            
            guard let strongSelf = self else {
                return
            }
            
            do {
                
                strongSelf.userListener!.remove()
                print("listener removed in signout method")
                
                try Auth.auth().signOut()
                
                GIDSignIn.sharedInstance()?.signOut()
                
                strongSelf.transitionToMainPage()
                
            } catch let error as NSError{
                
                strongSelf.showError(error.localizedDescription)
                print("Error logging out")
            }
        }))
        
        // Add a cancel action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        // Show the action sheet
        present(actionSheet, animated: true, completion: nil)
        
        
        
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
    
    func transitionToMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainPageNC = storyboard.instantiateViewController(identifier: Constants.Storyboard.mainPageNavigationController) as! MainPageNavigationController
        
        mainPageNC.modalPresentationStyle = .fullScreen
        mainPageNC.modalTransitionStyle = .flipHorizontal
        
        present(mainPageNC, animated: true, completion: nil)
        
        // not sure if should change to performsegue instead
        
        print("transitioning to main page")
        
    }
    
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
        
        // Update the database after user is done editing profile
        if let editProfileVC = unwindSegue.source as? EditProfileViewController {
            
            // Create cleaned versions of the data
            let editedFirstName = editProfileVC.editedFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let editedLastName = editProfileVC.editedLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let editedFavHobby = editProfileVC.editedFavHobby.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let editedOccupation = editProfileVC.editedOccupation.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var editedBio: String
            if editProfileVC.editedBio.text != "A short description about yoursef" {
                editedBio = editProfileVC.editedBio.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                editedBio = ""
            }
            
            // Updated data to be stored to database
            let data: [String: Any] = [
                "firstName" : editedFirstName,
                "lastName" : editedLastName,
                "favHobby" : editedFavHobby,
                "occupation" : editedOccupation,
                "bio" : editedBio
            ]
            
            FirebaseFirestoreManager.shared.updateUserProfileInformation(for: user!.uid, with: data) { success in
                
                if success {
                    
                    print("Successfully updated profile information")
                    
                } else {
                    
                    print("Failed to update profile information")
                    
                }
                
            }
        }
        else if unwindSegue.source is EditPhotoViewController {
            
            print("unwinding from edit photo")
            
            // Update to show latest user profile pic
            loadProfileImage()
            
        }
        
    }
    
}
