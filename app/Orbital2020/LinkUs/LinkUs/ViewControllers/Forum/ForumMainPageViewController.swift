//
//  ForumMainPageViewController.swift
//  LinkUs
//
//  Created by macos on 8/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ForumMainPageViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var forumTableView: UITableView!
    
    var user: LoginUser?
    
    var forumQuestionList = [ForumPost]()

    
    // For searching
    var searchForumQuestionList = [ForumPost]()
    var isSearching = false
    
    var forumListListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpForumListListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        forumQuestionList.removeAll()
        
        forumListListener!.remove()
        print("forumlist listener removed in viewdiddisappear")
    
    }
    
    deinit {
        forumListListener?.remove()
        print("deinit of forum main page called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user

        }
        
        self.navigationItem.hidesBackButton = true
        
        forumTableView.delegate = self
        forumTableView.dataSource = self
        searchBar.delegate = self
        
        // Adjust the row height of each option
        forumTableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        forumTableView.tableFooterView = UIView()
        
        
    }
    
    func setUpForumListListener() {
        
        let db = Firestore.firestore()
        let forumRef = db.collection("forum").order(by: "timestamp", descending: true).limit(to: 10)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the forumList will be updated in realtime when a new post is made (realtime listener is better than fetching data everytime the user clicks on the forum tab)
        forumListListener = forumRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime forum list updates: \(error?.localizedDescription ?? "no error")")
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
        case .added:  // when a new forum post is added to the database
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
            
            forumQuestionList.append(ForumPost(category: category, title: title, details: details, posterUid: posterUid, posterFullName: posterFullName, postDate: postDate, forumPostUid: forumPostUid, upvotes: upvotes, downvotes: downvotes, upvotedUsersUidList: upvotedUsersUidList, downvotedUsersUidList: downvotedUsersUidList))
            
            // latest post will be on top
            forumQuestionList.sort { (qns1, qns2) -> Bool in
                switch qns1.postDate.compare(qns2.postDate) {
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
                self.forumTableView.reloadData()
            }
            
            
        case .modified:
            break
            
        case .removed:
            break
        }
        
    }
    
    @IBAction func unwindToForumMainPage(unwindSegue: UIStoryboardSegue) {
    }
    

}

// MARK: - TableView Delegate Methods

extension ForumMainPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return searchForumQuestionList.count
        } else {
            return forumQuestionList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "forumCell", for: indexPath)
        
        
        if isSearching {
            cell.textLabel?.text = searchForumQuestionList[indexPath.row].title
        } else {
            cell.textLabel?.text = forumQuestionList[indexPath.row].title
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forumPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.forumPageViewController) as! ForumPageViewController
        
        forumPageVC.title = forumQuestionList[indexPath.row].title
        forumPageVC.forumPostClicked = forumQuestionList[indexPath.row]
        forumPageVC.user = self.user
        
        
        // Push the chat viewcontroller onto the navigation stack
        self.navigationController?.pushViewController(forumPageVC, animated: true)
        
    }
    
}


// MARK: - SearchBar Delegate Methods

extension ForumMainPageViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        isSearching = true
        searchForumQuestionList = forumQuestionList.filter({ $0.title.lowercased().prefix(searchText.count) == searchText.lowercased() })
        
        // Anything UI related should occur on main thread
        DispatchQueue.main.async {
            self.forumTableView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearching = false
        searchBar.text = ""
        
        // Anything UI related should occur on main thread
        DispatchQueue.main.async {
            self.forumTableView.reloadData()
        }
        
    }
    
}


