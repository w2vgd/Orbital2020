//
//  MSMyApplicationsViewController.swift
//  LinkUs
//
//  Created by macos on 14/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSMyApplicationsViewController: UIViewController {
    
    @IBOutlet weak var myApplicationsTableView: UITableView!
    
    var user: LoginUser?
    
    var applicationsUidList = [String]()
    var applicationsUidToStatusMap = [String : String]()
    
    var myApplicationsListListener: ListenerRegistration?
    
    var applicationClicked: MSUserApplication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpMyApplicationsListListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        myApplicationsListListener!.remove()
        print("myapplicationslist listener removed in viewdiddisappear")
        
    }
    
    deinit {
        myApplicationsListListener?.remove()
        print("deinit of myapplications vc called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user

        }
        
        myApplicationsTableView.delegate = self
        myApplicationsTableView.dataSource = self
        
        // Adjust the row height of each option
        myApplicationsTableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        myApplicationsTableView.tableFooterView = UIView()
        
    }
    
    func setUpMyApplicationsListListener() {
        
        let db = Firestore.firestore()
        let myApplicationsRef = db.collection("myApplications").document(self.user!.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say myApplications will be updated in realtime when a match is confirmed (realtime listener is better than fetching data everytime there is a new application)
        myApplicationsListListener = myApplicationsRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime myApplications updates: \(error?.localizedDescription ?? "no error")")
                return
            }
            let data = snapshot.data()!
            
            strongSelf.applicationsUidList = data["applicationsUidList"] as! [String]
            strongSelf.applicationsUidToStatusMap = data["applicationsUidToStatusMap"] as! [String : String]
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.myApplicationsTableView.reloadData()
            }
        }
        
    }
    
    
    @IBAction func unwindToMSMyApplications(unwindSegue: UIStoryboardSegue) {
    }
    
    
    
}


// MARK: - TableView Delegate Methods

extension MSMyApplicationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return applicationsUidList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myApplicationCell", for: indexPath)
        
        let applicationUid = applicationsUidList[indexPath.row]
        
        cell.textLabel?.text = "Application ID: " + applicationUid
        
        let applicationStatus = applicationsUidToStatusMap[applicationUid]
        
        switch applicationStatus {
        case "Pending":
            cell.accessoryType = .disclosureIndicator
            
        case "Matched":
            cell.accessoryType = .disclosureIndicator
            
        case "Completed":
            cell.accessoryType = .checkmark
            
        default:
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let applicationPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.myApplicationPageViewController) as! MSApplicationPageViewController
        
        applicationPageVC.title = applicationsUidList[indexPath.row]
        
        // Retrieve the application details from Firebase when user clicks on the application
        
        let applicationUid = applicationsUidList[indexPath.row]
        
        let db = Firestore.firestore()
        let applicationRef = db.collection("applications").document(applicationUid)
        
        applicationRef.getDocument { [weak self] document, error in
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                print("Error retrieving application from database: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                
                let data = document.data()!
                    
                var userCategory: MSCategoryOption?
                var userOccupation: MSOccupationOption?
                let userParagraph = data["userParagraph"]  as! String
                let userUid = data["userUid"] as! String
                let userFullName = data["userFullName"] as! String
                let applicationStatus = data["applicationStatus"] as! String
                let matchedExpertUid = data["matchedExpertUid"] as? String
                let matchedExpertFullName = data["matchedExpertFullName"] as? String
                let hasUserSubmittedReview = data["hasUserSubmittedReview"] as! Bool
                
                switch data["userCategory"] as! String {
                case "University Course":
                    userCategory = MSCategoryOption.UniCourse
                case "Working Life":
                    userCategory = MSCategoryOption.WorkingLife
                case "Career Opportunities":
                    userCategory = MSCategoryOption.Career
                default:
                    print("Error in switch case")
                }
                
                switch data["userOccupation"] as! String {
                case "Studying":
                    userOccupation = MSOccupationOption.Studying
                case "Employed":
                    userOccupation = MSOccupationOption.Employed
                case "Unemployed":
                    userOccupation = MSOccupationOption.Unemployed
                default:
                    print("Error in switch case")
                }
                
                // Create a MSUserApplication for the application form retrieved
                var userApplication = MSUserApplication(userUid: userUid, userFullName: userFullName)
                userApplication.applicationUid = applicationUid
                userApplication.category = userCategory
                userApplication.occupation = userOccupation
                userApplication.paragraph = userParagraph
                userApplication.applicationStatus = applicationStatus
                userApplication.matchedExpertUid = matchedExpertUid
                userApplication.matchedExpertFullName = matchedExpertFullName
                userApplication.hasUserSubmittedReview = hasUserSubmittedReview
                
                strongSelf.applicationClicked = userApplication
                
                // Pass the MSUserApplciation to the next viewcontroller
                applicationPageVC.applicationClicked = strongSelf.applicationClicked
                
                // Push the next viewcontroller onto the navigation stack after everything
                strongSelf.navigationController?.pushViewController(applicationPageVC, animated: true)
                
            }
            
        }
        
    }
    
    
}


