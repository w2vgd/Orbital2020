//
//  ForumNavigationController.swift
//  LinkUs
//
//  Created by macos on 8/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ForumNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
}


// MARK: - Methods used previously for other purposes

//var user: LoginUser?

//var forumListListener: ListenerRegistration?

//var forumQuestionList = [ForumPost]()

/*
deinit {
    forumListListener?.remove()
}

func setUpElements() {
    
    if let homeTabBarController = self.tabBarController as? HomeTabBarController {
        
        self.user = homeTabBarController.user
        
    }
    
    let forumRef = Firestore.firestore().collection("forum").order(by: "timestamp", descending: true).limit(to: 15)
    
    // Realtime listener that gets called everytime thrs an update in the database, meaning to say the forumList will be updated in realtime when a new post is made (realtime listener is better than fetching data everytime the user clicks on the forum tab)
    forumListListener = forumRef.addSnapshotListener { (querySnapshot, error) in
        guard let snapshot = querySnapshot else {
            print("Error listening to realtime forum list updates: \(error?.localizedDescription ?? "no error")")
            return
        }
        
        snapshot.documentChanges.forEach { (change) in
            self.handleDocumentChange(change)
            
        }
        
        self.navigationController?.popToRootViewController(animated: false)
        self.performSegue(withIdentifier: "forumNCSegueToForumMainPageVC", sender: self)
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
        //messagesCollectionView.reloadData()
    case .modified:
        print("modified document in database called")
    case .removed:
        break
    }
    
}
*/
/*
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let forumMainPageVC = segue.destination as? ForumMainPageViewController {
        
        forumMainPageVC.user = self.user
        //forumMainPageVC.forumQuestionList = self.forumQuestionList
        
    }
    
}
*/
