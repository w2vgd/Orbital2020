//
//  ReportForumPostViewController.swift
//  LinkUs
//
//  Created by macos on 20/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ReportForumPostViewController: UIViewController {
    
    
    @IBOutlet weak var reportTableView: UITableView!
    
    @IBOutlet weak var reportTextView: UITextView!
    
    @IBOutlet weak var reportButton: UIButton!
    
    var user: LoginUser?
    
    var forumPostClicked: ForumPost?
    var forumReplyClicked: ForumReply?
    
    // Report options
    let options = [ReportOption.Spam, ReportOption.Harassment, ReportOption.UseOfProfanity, ReportOption.Others]
    
    var selectedOption: ReportOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        // Disable the report button initially
        reportButton.isEnabled = false
        
        reportTableView.delegate = self
        reportTableView.dataSource = self
        
        
        // Remove the extra separator lines below the options
        let footerView = UIView()
        footerView.backgroundColor = .clear
        reportTableView.tableFooterView = footerView
        
        // Modify the reportTextView to look like a UITextField
        reportTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        reportTextView.layer.borderWidth = 1.0
        reportTextView.layer.cornerRadius = 5.0
        
        reportTextView.delegate = self
        
        // Set placeholder text for reportTextView
        reportTextView.text = "Enter report description here"
        reportTextView.textColor = .lightGray
        
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
        var reportedUserUid: String?
        var reportedPostOrReplyUid: String?
        
        if forumPostClicked != nil {
            reportedUserUid = forumPostClicked!.posterUid
            reportedPostOrReplyUid = forumPostClicked!.forumPostUid
        } else if forumReplyClicked != nil {
            reportedUserUid = forumReplyClicked!.userUid
            reportedPostOrReplyUid = forumReplyClicked!.forumReplyUid
        }
        
        let data: [String : Any] = [
            "reportCategory" : self.selectedOption!.description,
            "reportDescription" : reportTextView.text ?? "",
            "reportingUserUid" : self.user!.uid,
            "reportedUserUid" : reportedUserUid ?? "",
            "timestamp" : Timestamp(),
            "reportedPostOrReplyUid" : reportedPostOrReplyUid ?? ""
        ]
        
        FirebaseFirestoreManager.shared.uploadNewForumReport(with: data) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // pop to previous viewcontroller
            // present alert saying successfully reported poster
            // Creating an alert
            let alert = UIAlertController(title: "Reported", message: "The poster has been successfully reported!", preferredStyle: .alert)
            
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: strongSelf.popBackToPreviousViewController))
            
            // Show the alert
            strongSelf.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func popBackToPreviousViewController(alert: UIAlertAction!) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}


// MARK: - TableView Delegate Methods

extension ReportForumPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportForumPostCell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row].description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedOption = options[indexPath.row]
        
        reportButton.isEnabled = true
        
    }
    
}

// MARK: - Textview Delegate Methods

extension ReportForumPostViewController: UITextViewDelegate {
    
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
            
            textView.text = "Enter report description here"
            textView.textColor = .lightGray
        }
    }
    
}
