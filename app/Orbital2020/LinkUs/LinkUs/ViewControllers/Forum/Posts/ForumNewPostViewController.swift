//
//  ForumNewPostViewController.swift
//  LinkUs
//
//  Created by macos on 8/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ForumNewPostViewController: UIViewController {
    
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var detailsTextView: UITextView!
    
    @IBOutlet weak var postQuestionButton: UIButton!
    
    var user: LoginUser?
    
    let offensiveWords = ["idiot", "retard"]  // Add more if needed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        self.navigationItem.hidesBackButton = true
        
        // Modify the detailsTextView to look like a UITextField
        detailsTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        detailsTextView.layer.borderWidth = 1.0
        detailsTextView.layer.cornerRadius = 5.0
        
        detailsTextView.delegate = self
        
        // Set placeholder text for paragraph
        detailsTextView.text = "Enter details about your question"
        detailsTextView.textColor = .lightGray
        
        Utilities.styleBlueBorderButton(postQuestionButton)
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user

        }
        
    }
    
    @IBAction func postQuestionButtonTapped(_ sender: Any) {
        
        // Ensure there are no offensive words in the forum post
        let categoryText = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let titleText = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let detailsText = detailsTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        
        if containOffensiveWords(text: categoryText, offensiveWords: offensiveWords) || containOffensiveWords(text: titleText, offensiveWords: offensiveWords) || containOffensiveWords(text: detailsText, offensiveWords: offensiveWords) {
            
            // Creating an alert
            let alert = UIAlertController(title: "Offensive language detected!", message: "We have detected the use of offensive language in your post. Please ensure that your post do not contain offensive language before posting it.", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
            // Show the alert
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        let data: [String : Any] = [
            "category" : categoryTextField.text ?? "",
            "title" : titleTextField.text ?? "",
            "details" : detailsTextView.text ?? "",
            "posterUid" : self.user!.uid,
            "posterFullName" : self.user!.firstName + " " + self.user!.lastName,
            "timestamp" : Timestamp(),
            //"forumPostUid" : forumDocRef.documentID,
            "upvotes" : 0,
            "downvotes" : 0,
            "upvotedUsersUidList" : [String](),
            "downvotedUsersUidList" : [String]()
        ]
        
        FirebaseFirestoreManager.shared.uploadNewForumPost(with: data) { success in
            
            guard success else {
                print("failed to upload new forum post")
                return
            }
            
            print("Successfully uploaded new forum post")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func containOffensiveWords(text: String, offensiveWords: [String]) -> Bool {
        
        return offensiveWords.reduce(false) { $0 || text.contains($1.lowercased()) }
        
    }
    
}



// MARK: - Textview Delegate Methods

extension ForumNewPostViewController: UITextViewDelegate {
    
    /*
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // To limit the number of characters in detailsTextView to 1500
        let newLength = (textView.text ?? "").count + text.count - range.length
        return newLength <= 1500
        
    }
    */
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
            
            textView.text = "Enter details about your question"
            textView.textColor = .lightGray
        }
    }
    
}
