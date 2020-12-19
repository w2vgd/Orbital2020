//
//  EditProfileViewController.swift
//  LinkUs
//
//  Created by macos on 27/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    
    @IBOutlet weak var editedFirstName: UITextField!
    
    @IBOutlet weak var editedLastName: UITextField!
    
    @IBOutlet weak var editedFavHobby: UITextField!
    
    @IBOutlet weak var editedOccupation: UITextField!
    
    @IBOutlet weak var editedBio: UITextView!
    
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        // Disable the done button initially
        doneEditingButton.isEnabled = false
        
        // Modify the editedBio UITextView to look like a UITextField
        editedBio.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        editedBio.layer.borderWidth = 1.0
        editedBio.layer.cornerRadius = 5.0
        
        editedBio.delegate = self
        
        // Set placeholder text for editedBio
        editedBio.text = "A short description about yourself"
        editedBio.textColor = .lightGray
    }
    
    // Function to enable the done button only after user filled in all fields
    @IBAction func editingChanged(_ sender: UITextField) {
        
        if editedFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || editedLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || editedFavHobby.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            || editedOccupation.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            doneEditingButton.isEnabled = false
            
        } else {
            
            doneEditingButton.isEnabled = true
            
        }
        
    }
    
}


// MARK: - editedBio Textview Delegate Methods

extension EditProfileViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // To limit the number of characters in editedBio to 200 
        let newLength = (textView.text ?? "").count + text.count - range.length
        return newLength <= 200
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            
            textView.text = nil
            textView.textColor = .black
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = "A short description about yourself"
            textView.textColor = .lightGray
        }
    }

}
