//
//  ForumPageViewController.swift
//  LinkUs
//
//  Created by macos on 8/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ForumPageViewController: UIViewController {
    
    
    @IBOutlet weak var postTableView: UITableView!
    
    var bookmarkButton: UIBarButtonItem!
    
    var forumPostClicked: ForumPost?
    var forumReplies = [ForumReply]()
    
    var user: LoginUser?
    
    var forumPostListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpForumPostListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        forumReplies.removeAll()
        
        forumPostListener!.remove()
        print("forumpost listener removed in viewdiddisappear")
    
    }
    
    deinit {
        forumPostListener?.remove()
        print("deinit of forumpageview vc called")
    }
    
    func setUpElements() {
        
        // Create the Inbox button
        bookmarkButton = UIBarButtonItem(title: "Bookmark", style: .done, target: self, action: #selector(bookmarkButtonTapped))
        
        // Set the Inbox button as the right bar button item
        self.navigationItem.rightBarButtonItem = bookmarkButton
        
        postTableView.register(ForumPostTableViewCell.nib(), forCellReuseIdentifier: ForumPostTableViewCell.identifier)
        postTableView.register(ForumReplyTableViewCell.nib(), forCellReuseIdentifier: ForumReplyTableViewCell.identifier)
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        postTableView.tableFooterView = UIView()
        
    }
    
    func setUpForumPostListener() {
        
        let forumPostUid = self.forumPostClicked!.forumPostUid
        
        let db = Firestore.firestore()
        let forumPostRef = db.collection("forum").document(forumPostUid)
        
        let repliesRef = forumPostRef.collection("replies")//.order(by: "timestamp", descending: true)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the forum thread will be updated in realtime when there is a new reply (realtime listener is better than fetching data everytime there is a new reply)
        forumPostListener = repliesRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime forum post updates: \(error?.localizedDescription ?? "no error")")
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
        case .added:  // when a reply is added to the database
            
            let newReply = ForumReply(replyText: data["replyText"] as! String,
                                      userUid: data["userUid"] as! String,
                                      userFullName: data["userFullName"] as! String,
                                      replyDate: (data["timestamp"] as! Timestamp).dateValue(),
                                      forumReplyUid: data["forumReplyUid"] as! String,
                                      upvotes: data["upvotes"] as! Int,
                                      downvotes: data["downvotes"] as! Int,
                                      upvotedUsersUidList: data["upvotedUsersUidList"] as? [String] ?? [],
                                      downvotedUsersUidList: data["downvotedUsersUidList"] as? [String] ?? [])
            
            forumReplies.append(newReply)
            
            // latest reply will be at the bottom
            forumReplies.sort { (reply1, reply2) -> Bool in
                switch reply1.replyDate.compare(reply2.replyDate) {
                case .orderedAscending:
                    return true
                case .orderedSame:
                    return true
                case .orderedDescending:
                    return false
                }
            }
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                self.postTableView.reloadData()
            }
            
            
        case .modified:
            break
        case .removed:
            break
        }
        
    }
    
    @objc func bookmarkButtonTapped() {
        
        FirebaseFirestoreManager.shared.uploadNewBookmarkForumPost(for: user!.uid, forumPost: forumPostClicked!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // Creating an alert
            let alert = UIAlertController(title: "Done", message: "Successfully added to my bookmarks!", preferredStyle: .alert)

            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

            // Show the alert
            strongSelf.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func unwindToForumPageView(unwindSegue: UIStoryboardSegue) {
    }
    
    
}


// MARK: - TableView Delegate Methods

extension ForumPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return forumReplies.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ForumPostTableViewCell.identifier, for: indexPath) as! ForumPostTableViewCell
            
            cell.delegate = self
            cell.configure(with: forumPostClicked!, user: self.user!)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ForumReplyTableViewCell.identifier, for: indexPath) as! ForumReplyTableViewCell
            
            cell.delegate = self
            cell.forumPostClicked = self.forumPostClicked
            cell.forumReply = forumReplies[indexPath.row - 1]
            cell.user = self.user
            cell.configure(with: forumReplies[indexPath.row - 1], user: self.user!)
            
            return cell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}


// MARK: - ForumPostTableViewCell Delegate Methods

extension ForumPageViewController: ForumPostTableViewCellDelegate{
    
    func upvoteButtonTapped() {
        
        self.forumPostClicked!.upvotes += 1
        self.forumPostClicked!.upvotedUsersUidList.append(self.user!.uid)
        
        FirebaseFirestoreManager.shared.upvoteButtonTappedForForumPost(by: user!.uid, forumPost: forumPostClicked!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // Reload the tableview to show the latest info
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.postTableView.reloadData()
            }
            
            let userFullName = strongSelf.user!.firstName + " " + strongSelf.user!.lastName
            
            FirebaseFirestoreManager.shared.updateTotalUpvoteCount(userUid: strongSelf.user!.uid, userFullName: userFullName, for: strongSelf.forumPostClicked!.posterUid, forumPostUid: strongSelf.forumPostClicked!.forumPostUid) { updatedTotalUpvoteCount in
                
                guard updatedTotalUpvoteCount else {
                    return
                }
                
                print("Successfully updated total upvote count")
            }
        }
    }
    
    func downvoteButtonTapped() {
        
        self.forumPostClicked!.downvotes += 1
        self.forumPostClicked!.downvotedUsersUidList.append(self.user!.uid)
        
        FirebaseFirestoreManager.shared.downvoteButtonTappedForForumPost(by: user!.uid, forumPost: forumPostClicked!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // Reload the tableview to show the latest info
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.postTableView.reloadData()
            }
            
            let userFullName = strongSelf.user!.firstName + " " + strongSelf.user!.lastName
            
            FirebaseFirestoreManager.shared.updateTotalDownvoteCount(userUid: strongSelf.user!.uid, userFullName: userFullName, for: strongSelf.forumPostClicked!.posterUid, forumPostUid: strongSelf.forumPostClicked!.forumPostUid) { updatedTotalDownvoteCount in
                
                guard updatedTotalDownvoteCount else {
                    return
                }
                
                print("Successfully updated total downvote count")
            }
            
        }
        
    }
    
    func replyButtonTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let replyVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.forumReplyViewController) as! ForumReplyViewController
        
        replyVC.title = "Reply"
        replyVC.forumPostClicked = self.forumPostClicked
        replyVC.user = self.user
        
        // Push the reply viewcontroller onto the navigation stack
        self.navigationController?.pushViewController(replyVC, animated: true)
        
    }
    
    
    func reportButtonTapped() {
        print("report button tapped")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reportForumPostVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.reportForumPostViewController) as! ReportForumPostViewController
        
        reportForumPostVC.title = "Report"
        
        // Pass the MSUserApplciation to the next viewcontroller
        reportForumPostVC.forumPostClicked = self.forumPostClicked
        
        // Push the next viewcontroller onto the navigation stack after everything
        self.navigationController?.pushViewController(reportForumPostVC, animated: true)
    }
    
    
}


// MARK: - ForumReplyTableViewCell Delegate Methods

extension ForumPageViewController: ForumReplyTableViewCellDelegate{
    
    func replyUpvoteButtonTapped() {
        
        // Method body is called in ForumReplyTableViewCell instead because need to access the indexPath.row property in cellForRowAt method to get the corresponding ForumReply object at which the upvote button is pressed
        // Anything UI related should occur on main thread
        DispatchQueue.main.async {
            self.postTableView.reloadData()
        }
        
    }
    
    func replyDownvoteButtonTapped() {
        
        // Method body is called in ForumReplyTableViewCell instead because need to access the indexPath.row property in cellForRowAt method to get the corresponding ForumReply object at which the downvote button is pressed
        // Anything UI related should occur on main thread
        DispatchQueue.main.async {
            self.postTableView.reloadData()
        }
        
    }
    
    func replyReportButtonTapped(reportedForumReply: ForumReply) {
        
        print(" reply report button tapped")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let reportForumPostVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.reportForumPostViewController) as! ReportForumPostViewController
        
        reportForumPostVC.title = "Report"
        
        // Pass the MSUserApplciation to the next viewcontroller
        reportForumPostVC.forumReplyClicked = reportedForumReply
        
        // Push the next viewcontroller onto the navigation stack after everything
        self.navigationController?.pushViewController(reportForumPostVC, animated: true)
        
    }
    
    
    
}


