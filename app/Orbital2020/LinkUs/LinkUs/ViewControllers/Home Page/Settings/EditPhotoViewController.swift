//
//  EditPhotoViewController.swift
//  LinkUs
//
//  Created by macos on 27/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class EditPhotoViewController: UIViewController {

    @IBOutlet weak var placeholderImageView: UIImageView!
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    var doneButton: UIBarButtonItem!
    
    var user: LoginUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        print("setting up")
        // Tries to load the current user profile photo if it exist
        loadUserPhoto()
        
        // To make the placeholderImageView circular with a border
        placeholderImageView.layer.masksToBounds = true
        placeholderImageView.layer.borderWidth = 2
        placeholderImageView.layer.borderColor = UIColor.lightGray.cgColor
        placeholderImageView.layer.cornerRadius = placeholderImageView.frame.size.width / 2.0
        
        // To make the userPhotoImageView circular with a border
        userPhotoImageView.layer.masksToBounds = true
        userPhotoImageView.layer.borderWidth = 2
        userPhotoImageView.layer.borderColor = UIColor.lightGray.cgColor
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.width / 2.0
        
        // Enable user to tap the userPhotoImageView
        userPhotoImageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        userPhotoImageView.addGestureRecognizer(gesture)
        
        // Create the done button
        doneButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(doneButtonTapped))
        
        self.navigationItem.rightBarButtonItem = doneButton
        
        
    }
    
    func loadUserPhoto() {
        
        // User's profile image path (if it exist)
        let path = "images/" + self.user!.profilePictureFileName
        
        /* Might need to fix because this keeps downloading url from firebase */
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                // Successfully gotten photo url from storage, now download the photo from the url and display it
                DispatchQueue.main.async {
                    strongSelf.userPhotoImageView.sd_setImage(with: url, completed: nil)
                    
                    // Only display the user profile photo by hiding the placeholder image
                    strongSelf.placeholderImageView.isHidden = true
                }
                
            case .failure(let error):
                
                // Failed to get photo url from storage (mainly due to user not having a profile photo in the first place)
                print("failed to get download url: \(error)")
                
                // Just show the default person.circle image
                // Note that the userPhotoImageView background color is clear by default so it looks like theres only one imageview
                
            }
        }
        
    }
    
    @objc private func didTapChangeProfilePic() {
        
        print("didTapChangeProfilePic called")
        presentPhotoActionSheet()
        
    }
    
    @objc private func doneButtonTapped() {
        
        guard let image = self.userPhotoImageView.image,
            let data = image.pngData() else {
                
                // No image selected
                
                print("no image selected")
                
                let path = "images/" + self.user!.profilePictureFileName
                
                // Attempt to delete the current user profile image in Firebase storage if it exist
                FirebaseStorageManager.shared.deleteProfilePicture(for: path, completion: { [weak self] success in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if success {
                        
                        strongSelf.performSegue(withIdentifier: "editPhotoUnwindSegueToHome", sender: self)
                        
                    } else {
                        
                        print("Error deleting profile picture")
                        
                    }
                    
                    
                    
                })
                
            return
        }
        
        let fileName = self.user!.profilePictureFileName
        
        // Upload the image selected to Firebase Storage
        FirebaseStorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
            
            switch result {
            case .success(let downloadUrl):
                
                UserDefaults.standard.set(downloadUrl, forKey: "\(self.user!.uid)_profile_picture_url")
                
            case .failure(let error):
                
                print("StorageManager error: \(error)")
                
            }
            
            self.performSegue(withIdentifier: "editPhotoUnwindSegueToHome", sender: self)
            
        }
        
    }
    
    
    
}


// MARK: - Image Picker Delegate Methods

extension EditPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        // Create an action sheet prompt to let user choose to select photo from photo gallery
        
        // Creating an actionsheet
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        // Add a cancel action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        // Add an action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
        }))
        
        // Add an action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Remove Profile Photo", style: .default, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            // Removes the current user profile photo
            strongSelf.userPhotoImageView.image = nil
            
            // Shows the placeholderImageView when the user removes the current profile photo
            strongSelf.placeholderImageView.isHidden = false
            
            
        }))
        
        
        // Show the action sheet
        present(actionSheet, animated: true)
    }
    
    func presentPhotoPicker() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        // Display the photo the user picked from gallery in the userPhotoImageView
        self.userPhotoImageView.image = selectedImage
        
        // Hides the default placeholderImageView once user has picked an image
        self.placeholderImageView.isHidden = true
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
