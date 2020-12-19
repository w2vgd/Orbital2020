//
//  MatchingSystemStep2ViewController.swift
//  LinkUs
//
//  Created by macos on 29/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class MSStep2ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var paragraph: UITextView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var applicationForm: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Disable the next button initially
        nextButton.isEnabled = false
        
        // Modify the paragraph UITextView to look like a UITextField
        paragraph.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        paragraph.layer.borderWidth = 1.0
        paragraph.layer.cornerRadius = 5.0
        
        paragraph.delegate = self
        
        // Set placeholder text for paragraph
        paragraph.text = "Please enter a maximum of around 300 words"
        paragraph.textColor = .lightGray
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? MSStep3ViewController {
            
            self.applicationForm!.paragraph = paragraph.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            destinationVC.applicationForm = self.applicationForm
            
        }
    }
    
    // Maybe can change to fill in a certain number of characters??
    // Enable the next button only after user filled in something in the paragraph
    func textViewDidChange(_ textView: UITextView) {
        
        if paragraph.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            nextButton.isEnabled = false
            
        } else {
            
            nextButton.isEnabled = true
            
        }
        
    }
    
    
    // MARK: - paragraph Textview Delegate Methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // To limit the number of characters in paragraph to 1500
        let newLength = (textView.text ?? "").count + text.count - range.length
        return newLength <= 1500
        
    }
    
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
            
            textView.text = "Please enter a maximum of around 300 words"
            textView.textColor = .lightGray
        }
    }


}
