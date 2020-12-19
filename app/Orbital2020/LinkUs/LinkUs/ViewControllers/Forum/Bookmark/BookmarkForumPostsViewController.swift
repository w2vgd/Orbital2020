//
//  BookmarkForumPostsViewController.swift
//  LinkUs
//
//  Created by macos on 17/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class BookmarkForumPostsViewController: UIViewController {
    
    @IBOutlet weak var bookmarkForumPostsTableView: UITableView!
    
    var user: LoginUser?
    
    var forumPostUidList = [String]()
    var forumPostUidToTitleMap = [String : String]()
    
    var myForumBookmarksListener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpMyForumBookmarksListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        myForumBookmarksListener!.remove()
        print("myforumbookmarks listener removed in viewdiddisappear")
    
    }
    
    deinit {
        myForumBookmarksListener?.remove()
        print("deinit of forumbookmarks called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user

        }
        
        bookmarkForumPostsTableView.delegate = self
        bookmarkForumPostsTableView.dataSource = self
        
        // Adjust the row height of each option
        bookmarkForumPostsTableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        bookmarkForumPostsTableView.tableFooterView = UIView()
        
    }
    
    func setUpMyForumBookmarksListener() {
        
        let myForumBookmarkRef = Firestore.firestore().collection("myForumBookmarks").document(self.user!.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say myReviews will be updated in realtime (realtime listener is better than fetching data everytime there is an update to myReviews)
        myForumBookmarksListener = myForumBookmarkRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime forum bookmarks updates: \(error?.localizedDescription ?? "no error")")
                return
            }
            let data = snapshot.data()!
            
            strongSelf.forumPostUidList = data["forumPostUidList"] as! [String]
            strongSelf.forumPostUidToTitleMap = data["forumPostUidToTitleMap"] as! [String : String]
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.bookmarkForumPostsTableView.reloadData()
            }
            
            
        }
        
    }
    
}


// MARK: - TableView Delegate Methods

extension BookmarkForumPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return forumPostUidList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkForumCell", for: indexPath)
        
        let forumPostUid = forumPostUidList[indexPath.row]
        let title = forumPostUidToTitleMap[forumPostUid]!
        
        cell.textLabel?.text = title
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        let forumPostUid = forumPostUidList[indexPath.row]
        
        let db = Firestore.firestore()
        let forumPostRef = db.collection("forum").document(forumPostUid)
        
        forumPostRef.getDocument { (document, error) in
            if let error = error {
                print("Error retrieving forum post from database: \(error.localizedDescription)")
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
                
                let forumPostClicked =
                        ForumPost(category: category,
                                  title: title,
                                  details: details,
                                  posterUid: posterUid,
                                  posterFullName: posterFullName,
                                  postDate: postDate,
                                  forumPostUid: forumPostUid,
                                  upvotes: upvotes,
                                  downvotes: downvotes,
                                  upvotedUsersUidList: upvotedUsersUidList,
                                  downvotedUsersUidList: downvotedUsersUidList)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let forumPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.forumPageViewController) as! ForumPageViewController
                
                forumPageVC.title = title
                forumPageVC.forumPostClicked = forumPostClicked
                forumPageVC.user = self.user
                
                
                // Push the chat viewcontroller onto the navigation stack
                self.navigationController?.pushViewController(forumPageVC, animated: true)
                
                
            }
        }
        
        
    }
    
}
