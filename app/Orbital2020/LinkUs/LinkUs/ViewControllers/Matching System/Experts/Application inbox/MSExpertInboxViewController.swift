//
//  MSExpertInboxViewController.swift
//  LinkUs
//
//  Created by macos on 31/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSExpertInboxViewController: UIViewController {
    
    @IBOutlet weak var userApplicationsTableView: UITableView!
    
    var user: LoginUser?
    
    var applicationsUidList = [String]()
    var applicationsUidToUserFullNameMap = [String : String]()
    
    var inboxApplicationsListener: ListenerRegistration?
    
    
    var applicationClicked: MSUserApplication?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpInboxApplicationsListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        inboxApplicationsListener!.remove()
        print("inboxApplications listener removed in viewdiddisappear")
        
    }
    
    deinit {
        inboxApplicationsListener?.remove()
        print("deinit of expertinboxapplications called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        userApplicationsTableView.delegate = self
        userApplicationsTableView.dataSource = self
        
        // Adjust the row height of each option
        userApplicationsTableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        userApplicationsTableView.tableFooterView = UIView()
        
    }
    
    func setUpInboxApplicationsListener() {
        
        let db = Firestore.firestore()
        let inboxApplicationRef = db.collection("inboxApplications").document(self.user!.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the inboxApplications will be updated in realtime when a match is confirmed (realtime listener is better than fetching data everytime there is a modification)
        inboxApplicationsListener = inboxApplicationRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime inboxApplications updates: \(error?.localizedDescription ?? "no error")")
                return
            }
            let data = snapshot.data()!
            
            strongSelf.applicationsUidList = data["applicationsUidList"] as! [String]
            strongSelf.applicationsUidToUserFullNameMap = data["applicationsUidToUserFullNameMap"] as! [String : String]
            
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.userApplicationsTableView.reloadData()
            }
        }
        
    }
    

}


// MARK: - TableView Delegate Methods

extension MSExpertInboxViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.applicationsUidList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath)
            
        let applicationUid = applicationsUidList[indexPath.row]
        let userFullName = applicationsUidToUserFullNameMap[applicationUid]!
            
        cell.textLabel?.text = "User:    " + userFullName
            
        // Add a small indicator at the right side of each cell
        cell.accessoryType = .disclosureIndicator
            
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Create a new MSApplicationFormViewController when the expert clicks to view an application form
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let applicationFormVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.applicationFormViewController) as! MSApplicationFormViewController
        
        applicationFormVC.title = "Application Form"
        
        
        // Retrieve the application details from Firebase when user clicks on the application
        
        let applicationUid = applicationsUidList[indexPath.row]
        let userFullName = applicationsUidToUserFullNameMap[applicationUid]!
        
        let db = Firestore.firestore()
        let applicationRef = db.collection("applications").document(applicationUid)
        
        applicationRef.getDocument { (document, error) in
            if let error = error {
                print("Error retrieving application from database: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                
                let data = document.data()!
                
                var userCategory: MSCategoryOption?
                var userOccupation: MSOccupationOption?
                let userParagraph = data["userParagraph"]  as! String
                let userUid = data["userUid"] as! String
                let applicationStatus = data["applicationStatus"] as! String
                
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
                
                self.applicationClicked = userApplication
                
                // Pass the MSUserApplciation to the next viewcontroller
                applicationFormVC.applicationClicked = self.applicationClicked
                
                // Push the next viewcontroller onto the navigation stack after everything
                self.navigationController?.pushViewController(applicationFormVC, animated: true)
            }
            
        }
        
    }
    
    
}

