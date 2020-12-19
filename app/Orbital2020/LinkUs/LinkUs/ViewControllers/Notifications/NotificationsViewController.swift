//
//  NotificationsViewController.swift
//  LinkUs
//
//  Created by macos on 28/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import FirebaseFirestore

class NotificationsViewController: UIViewController {

    @IBOutlet weak var notificationsTableView: UITableView!
    
    var user: LoginUser?
    
    var myNotifications = [MyNotification]()
    
    var myNotificationsListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpMyNotificationsListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        myNotifications.removeAll()
        
        myNotificationsListener!.remove()
        print("myNotifications listener removed in viewdiddisappear")
        
    }
    
    deinit {
        myNotificationsListener?.remove()
        print("deinit of notifications called")
    }
    
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        notificationsTableView.register(NotificationsTableViewCell.nib(), forCellReuseIdentifier: NotificationsTableViewCell.identifier)
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        
        notificationsTableView.tableFooterView = UIView()
        
    }
    
    func setUpMyNotificationsListener() {
        
        // limit to last 20 notifications
        let db = Firestore.firestore()
        let myNotificationsRef = db.collection("myNotifications").document(self.user!.uid).collection("notifications").order(by: "timestamp", descending: true).limit(to: 20)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the notifications will be updated in realtime
        myNotificationsListener = myNotificationsRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot, error == nil else {
                print("Error listening to realtime notifications updates: \(error!.localizedDescription)")
                return
            }
            
            snapshot.documentChanges.forEach { (change) in
                strongSelf.handleDocumentChange(change)
                
            }
            
        }
        
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        
        let data = change.document.data()
        
        switch change.type {
        case .added:  // when a new notification is added to the database
            
            let newNotification = MyNotification(
                                    byUserUid: data["byUserUid"] as! String,
                                    byUserFullName: data["byUserFullName"] as! String,
                                    category: data["category"] as! String,
                                    date: (data["timestamp"] as! Timestamp).dateValue(),
                                    forumPostUid: data["forumPostUid"] as? String,
                                    applicationUid: data["applicationUid"] as? String,
                                    reviewUid: data["reviewUid"] as? String)
            
            myNotifications.append(newNotification)
            
            // latest notification will be at the top
            myNotifications.sort { (notif1, notif2) -> Bool in
                switch notif1.date.compare(notif2.date) {
                case .orderedAscending:
                    return false
                case .orderedSame:
                    return false
                case .orderedDescending:
                    return true
                }
            }
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                self.notificationsTableView.reloadData()
            }
            
        case .modified:
            break
        case .removed:
            break
        }
        
    }
    
    
}


// MARK: - TableView Delegate Methods

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myNotifications.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.identifier, for: indexPath) as! NotificationsTableViewCell
        
        cell.configure(with: myNotifications[indexPath.row])
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch myNotifications[indexPath.row].category {
        case "upvote", "downvote", "reply":
            // View the forum thread
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forumPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.forumPageViewController) as! ForumPageViewController
            
            let forumPostUid = myNotifications[indexPath.row].forumPostUid!
            
            let db = Firestore.firestore()
            let forumPostRef = db.collection("forum").document(forumPostUid)
            
            forumPostRef.getDocument { [weak self] document, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    print("Error retrieving forumPost document from database: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                
                    let data = document.data()!
                    
                    let category = data["category"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let details = data["details"] as? String ?? ""
                    let posterUid = data["posterUid"] as? String ?? ""
                    let posterFullName = data["posterFullName"] as? String ?? ""
                    let postDate = (data["timestamp"] as! Timestamp).dateValue()
                    let forumPostUid = data["forumPostUid"] as! String
                    let upvotes = data["upvotes"] as! Int
                    let downvotes = data["downvotes"] as! Int
                    let upvotedUsersUidList = data["upvotedUsersUidList"] as? [String] ?? []
                    let downvotedUsersUidList = data["downvotedUsersUidList"] as? [String] ?? []
                    
                    let forumPostClicked = ForumPost(category: category, title: title, details: details, posterUid: posterUid, posterFullName: posterFullName, postDate: postDate, forumPostUid: forumPostUid, upvotes: upvotes, downvotes: downvotes, upvotedUsersUidList: upvotedUsersUidList, downvotedUsersUidList: downvotedUsersUidList)
                    
                    forumPageVC.title = title
                    forumPageVC.forumPostClicked = forumPostClicked
                    forumPageVC.user = strongSelf.user
                    
                    // Push the chat viewcontroller onto the navigation stack
                    strongSelf.navigationController?.pushViewController(forumPageVC, animated: true)
                }
                
            }
            
        case "match", "markComplete":
            // (for users) View the application
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let applicationPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.myApplicationPageViewController) as! MSApplicationPageViewController
            
            let applicationUid = myNotifications[indexPath.row].applicationUid!
            
            // Retrieve the application details from Firebase when user clicks on the application
            
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
                    
                    applicationPageVC.title = applicationUid
                    
                    // Pass the MSUserApplciation to the next viewcontroller
                    applicationPageVC.applicationClicked = userApplication
                    
                    // Push the next viewcontroller onto the navigation stack after everything
                    strongSelf.navigationController?.pushViewController(applicationPageVC, animated: true)
                }
            }
        
        case "newApplication":
            // (for expert) View the application
            
            // Create a new MSApplicationFormViewController when the expert clicks to view an application form
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let applicationFormVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.applicationFormViewController) as! MSApplicationFormViewController
            
            applicationFormVC.title = "Application Form"
            
            // Retrieve the application details from Firebase when user clicks on the application
            
            let applicationUid = myNotifications[indexPath.row].applicationUid!
            
            
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
                    let userFullName = data["userFullName"] as! String
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
                    
                    // Pass the MSUserApplciation to the next viewcontroller
                    applicationFormVC.applicationClicked = userApplication
                    
                    // Push the next viewcontroller onto the navigation stack after everything
                    self.navigationController?.pushViewController(applicationFormVC, animated: true)
                }
                
            }
            
        case "review":
            // View the review
            
            // Retrieve the review details from Firebase when expert clicks on the review
            
            let reviewUid = myNotifications[indexPath.row].reviewUid!
            
            let db = Firestore.firestore()
            let reviewRef = db.collection("reviews").document(reviewUid)
            
            reviewRef.getDocument { (document, error) in
                
                if let error = error {
                    print("Error retrieving review from database: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                
                    let data = document.data()!
                    
                    let userUid = data["userUid"] as! String
                    let userFullName = data["userFullName"] as! String
                    let ratings = data["ratings"] as! Double
                    let date = (data["timestamp"] as! Timestamp).dateValue()
                    let feedback = data["feedback"] as! String
                    
                    var reviewClicked = Review(reviewUid: reviewUid)
                    reviewClicked.userUid = userUid
                    reviewClicked.userFullName = userFullName
                    reviewClicked.ratings = ratings
                    reviewClicked.date = date
                    reviewClicked.feedback = feedback
                    
                    // Create a new ReviewPageVC when the expert clicks to view a review
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let reviewPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertReviewPageViewController) as! MSExpertReviewPageViewController
                    
                    reviewPageVC.title = "Review Details"
                    
                    reviewPageVC.reviewClicked = reviewClicked
                    
                    // Push the next viewcontroller onto the navigation stack after everything is done
                    self.navigationController?.pushViewController(reviewPageVC, animated: true)
                    
                }
            }
            
        default:
            print("Notifications category error")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
}

