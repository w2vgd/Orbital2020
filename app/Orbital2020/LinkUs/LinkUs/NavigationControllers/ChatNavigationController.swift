//
//  ChatNavigationController.swift
//  LinkUs
//
//  Created by macos on 3/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class ChatNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
}


// MARK: - Methods used previously for other purposes

//var user: LoginUser?

//var chatsListListener: ListenerRegistration?

/*
deinit {
    chatsListListener?.remove()
}
*/
/*
override func viewWillAppear(_ animated: Bool) {
    print("in viewwillappear of chatNC")
    
    setUpElements()
    
    fetchChatsList()
}
*/
/*
func setUpElements() {
    
    if let homeTabBarController = self.tabBarController as? HomeTabBarController {
        
        self.user = homeTabBarController.user
        
    }
    
    
    let chatsListRef = Firestore.firestore().collection("chatsList").document(self.user!.uid)
    
    // Realtime listener that gets called everytime thrs an update in the database, meaning to say the chatsList will be updated in realtime when a match is confirmed (realtime listener is better than fetching data everytime the user clicks on the chats tab)
    chatsListListener = chatsListRef.addSnapshotListener { (querySnapshot, error) in
        guard let snapshot = querySnapshot else {
            print("Error listening to realtime chatsList updates: \(error?.localizedDescription ?? "no error")")
            return
        }
        let data = snapshot.data()!
        
        self.user!.chatsList = ChatsList(
            matchedPartnersUidList: data["matchedPartnersUidList"] as? [String],
            matchedPartnersUidToNameMap: data["matchedPartnersUidToNameMap"] as? [String : String],
            matchedPartnersUidToChatUidMap: data["matchedPartnersUidToChatUidMap"] as? [String : String])
        
        
        // Update user variable in home TBC
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            homeTabBarController.user = self.user
            
        }
        
        self.performSegue(withIdentifier: "chatNCSegueToChatsListVC", sender: self)
    }
    
    
}
*/
/*
func fetchChatsList() {
        
    // When the chats tab is clicked, fetch the chatsList of the current user from the database and load the information
    let db = Firestore.firestore()
    
    // Get the chatsList of the current user
    let chatsListRef = db.collection("chatsList").document(self.user!.uid)
    
    chatsListRef.getDocument { (document, error) in
        
        if let document = document, document.exists {
            
            // Document successfully retrieved from the database
            
            let data = document.data()!

            self.user!.chatsList = ChatsList(
                matchedPartnersUidList: data["matchedPartnersUidList"] as? [String],
                matchedPartnersUidToNameMap: data["matchedPartnersUidToNameMap"] as? [String : String],
                matchedPartnersUidToChatUidMap: data["matchedPartnersUidToChatUidMap"] as? [String : String])
                
            
            print("assigned user's chats list in chat NC")
            
            // Update user variable in home TBC
            if let homeTabBarController = self.tabBarController as? HomeTabBarController {
                
                homeTabBarController.user = self.user
                
            }
            
            self.performSegue(withIdentifier: "chatNCSegueToChatsListVC", sender: self)
            
        }
    }
    
    
}
*/
/*
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let chatsListVC = segue.destination as? ChatsListViewController {
        
        chatsListVC.user = self.user
        
    }
    
}
*/
