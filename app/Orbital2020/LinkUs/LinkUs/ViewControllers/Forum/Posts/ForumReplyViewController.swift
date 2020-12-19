//
//  ForumReplyViewController.swift
//  LinkUs
//
//  Created by macos on 9/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ForumReplyViewController: UIViewController {
    
    var forumPostClicked: ForumPost?
    
    var user: LoginUser?
    
    @IBOutlet weak var replyTextView: UITextView!
    
    @IBOutlet weak var postReplyButton: UIButton!
    
    let offensiveWords = ["idiot", "retard"]    // Add more if needed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Modify the replyTextView to look like a UITextField
        replyTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        replyTextView.layer.borderWidth = 1.0
        replyTextView.layer.cornerRadius = 5.0
        
        replyTextView.delegate = self
        
        // Set placeholder text for paragraph
        replyTextView.text = "Enter your reply here"
        replyTextView.textColor = .lightGray
        
        Utilities.styleBlueBorderButton(postReplyButton)
    }
    
    
    @IBAction func postReplyButtonTapped(_ sender: Any) {
        
        // Ensure there are no offensive words in the forum post
        let replyText = replyTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        
        if containOffensiveWords(text: replyText, offensiveWords: offensiveWords) {
            
            // Creating an alert
            let alert = UIAlertController(title: "Offensive language detected!", message: "We have detected the use of offensive language in your post. Please ensure that your post do not contain offensive language before posting it.", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            
            // Show the alert
            present(alert, animated: true, completion: nil)
            return
        }
        
        let data: [String : Any] = [
            "replyText" : replyTextView.text ?? "",
            "userUid" : self.user!.uid,
            "userFullName" : self.user!.firstName + " " + self.user!.lastName,
            "timestamp" : Timestamp(),
            //"forumReplyUid" : forumDocRef.documentID,
            "upvotes" : 0,
            "downvotes" : 0,
            "upvotedUsersUidList" : [String](),
            "downvotedUsersUidList" : [String]()
        ]
        
        FirebaseFirestoreManager.shared.uploadNewForumReply(forumPost: forumPostClicked!, with: data) { success in
            
            guard success else {
                print("failed to upload new forum reply")
                return
            }
            
            print("Successfully uploaded new forum reply")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func containOffensiveWords(text: String, offensiveWords: [String]) -> Bool {
        
        return offensiveWords.reduce(false) { $0 || text.contains($1.lowercased()) }
        
    }
    
}


// MARK: - Textview Delegate Methods

extension ForumReplyViewController: UITextViewDelegate {
    
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
            
            textView.text = "Enter your reply here"
            textView.textColor = .lightGray
        }
    }
    
}

