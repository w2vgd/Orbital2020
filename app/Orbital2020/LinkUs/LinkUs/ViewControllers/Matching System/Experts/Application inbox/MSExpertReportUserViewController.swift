//
//  MSExpertReportUserViewController.swift
//  LinkUs
//
//  Created by macos on 15/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSExpertReportUserViewController: UIViewController {
    
    
    @IBOutlet weak var reportTableView: UITableView!
    
    @IBOutlet weak var reportDescriptionTextView: UITextView!
    
    @IBOutlet weak var reportButton: UIButton!
    
    var user: LoginUser?
    var applicationClicked: MSUserApplication?
    
    // Report options
    let options = [ReportOption.Spam, ReportOption.Harassment, ReportOption.UseOfProfanity, ReportOption.Others]
    
    var selectedOption: ReportOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        
        // Modify the reportDescriptionTextView to look like a UITextField
        reportDescriptionTextView.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1).cgColor
        reportDescriptionTextView.layer.borderWidth = 1.0
        reportDescriptionTextView.layer.cornerRadius = 5.0
        
        reportDescriptionTextView.delegate = self
        
        // Set placeholder text for reportDescriptionTextView
        reportDescriptionTextView.text = "Enter report description here"
        reportDescriptionTextView.textColor = .lightGray
        
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
        
        let data: [String : Any] = [
            "reportCategory" : self.selectedOption!.description,
            "reportDescription" : reportDescriptionTextView.text ?? "",
            "reportingUserUid" : self.user!.uid,
            "reportedUserUid" : self.applicationClicked!.userUid,
            "timestamp" : Timestamp()
        ]
        
        FirebaseFirestoreManager.shared.uploadNewReport(application: applicationClicked!, data: data) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // pop to previous viewcontroller
            // present alert saying successfully reported user
            // Creating an alert
            let alert = UIAlertController(title: "Reported", message: "User has been successfully reported!", preferredStyle: .alert)
            
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

extension MSExpertReportUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expertReportUserCell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row].description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedOption = options[indexPath.row]
        
        reportButton.isEnabled = true
        
    }
    
}

// MARK: - Textview Delegate Methods

extension MSExpertReportUserViewController: UITextViewDelegate {
    
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
