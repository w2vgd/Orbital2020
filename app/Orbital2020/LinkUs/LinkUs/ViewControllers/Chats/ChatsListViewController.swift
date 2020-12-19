//
//  ChatsListViewController.swift
//  LinkUs
//
//  Created by macos on 3/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import JGProgressHUD

class ChatsListViewController: UIViewController {
    
    // To show a spinning loading sign before the chat is loaded
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    var user: LoginUser?
    
    var chatsListListener: ListenerRegistration?
    
    // To display when user has no conversations yet
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(noConversationsLabel)
        setUpElements()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.frame.size.height - 100) / 2,
                                            width: view.frame.size.width - 20,
                                            height: 100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpChatsListListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        chatsListListener!.remove()
        print("chatslist listener removed in viewdiddisappear")
    
    }
    
    deinit {
        chatsListListener?.remove()
        print("deinit of chatslist vc called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        self.navigationItem.hidesBackButton = true
        
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        
        // Adjust the row height of each option
        chatsTableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        chatsTableView.tableFooterView = UIView()
        
        
    }
    
    func setUpChatsListListener() {
        
        let db = Firestore.firestore()
        let chatsListRef = db.collection("chatsList").document(self.user!.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the chatsList will be updated in realtime when a match is confirmed (realtime listener is better than fetching data everytime the user clicks on the chats tab)
        chatsListListener = chatsListRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime chatsList updates: \(error?.localizedDescription ?? "no error")")
                return
            }
            let data = snapshot.data()!
            
            strongSelf.user!.chatsList = ChatsList(
                matchedPartnersUidList: data["matchedPartnersUidList"] as? [String],
                matchedPartnersUidToNameMap: data["matchedPartnersUidToNameMap"] as? [String : String],
                matchedPartnersUidToChatUidMap: data["matchedPartnersUidToChatUidMap"] as? [String : String])
            
            
            // Update user variable in home TBC
            if let homeTabBarController = strongSelf.tabBarController as? HomeTabBarController {
                
                homeTabBarController.user = strongSelf.user
                
            }
            
            // Shows the "No conversations yet" label only if there are no matched partners
            if strongSelf.user!.chatsList!.matchedPartnersUidList?.count ?? 0 > 0 {
                strongSelf.noConversationsLabel.isHidden = true
            } else {
                strongSelf.noConversationsLabel.isHidden = false
            }
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.chatsTableView.reloadData()
            }
        }
        
    }

}

// MARK: - TableView Delegate Methods

extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.user!.chatsList != nil {
            return self.user!.chatsList!.matchedPartnersUidList!.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        
        if self.user!.chatsList != nil {
            
            let matchedPartnerUid = self.user!.chatsList!.matchedPartnersUidList![indexPath.row]
            let matchedPartnerFullName = self.user!.chatsList!.matchedPartnersUidToNameMap![matchedPartnerUid]
            
            cell.textLabel?.text = matchedPartnerFullName
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        let matchedPartnerUid = self.user!.chatsList!.matchedPartnersUidList![indexPath.row]
        let matchedPartnerFullName = self.user!.chatsList!.matchedPartnersUidToNameMap![matchedPartnerUid]
        let chatUid = self.user!.chatsList!.matchedPartnersUidToChatUidMap![matchedPartnerUid]
        
        let currSender = Sender(senderId: self.user!.uid, displayName: self.user!.firstName + " " + self.user!.lastName)
        let otherSender = Sender(senderId: matchedPartnerUid, displayName: matchedPartnerFullName!)
        
                
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as! ChatViewController
        
        chatVC.title = matchedPartnerFullName
        chatVC.user = self.user
        chatVC.currSender = currSender
        chatVC.otherSender = otherSender
        chatVC.chatUid = chatUid!
        chatVC.matchedPartnerUid = matchedPartnerUid
        
        // Push the chat viewcontroller onto the navigation stack
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
}

// MARK: - Methods used previously for other purposes
/*
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Retrieve the chat details from Firebase when user clicks on the chat
        
        let db = Firestore.firestore()
        let chatsRef = db.collection("chats")
        
        let matchedPartnerUid = self.user!.chatsList!.matchedPartnersUidList![indexPath.row]
        let matchedPartnerFullName = self.user!.chatsList!.matchedPartnersUidToNameMap![matchedPartnerUid]
        let chatUid = self.user!.chatsList!.matchedPartnersUidToChatUidMap![matchedPartnerUid]
        
        let chatRef = chatsRef.document(chatUid!)
        let messagesRef = chatRef.collection("messages").order(by: "timestamp", descending: true).limit(to: 15)
        
        // Array of messages to be loaded from database
        var messages = [MessageType]()
        
        let currSender = Sender(senderId: self.user!.uid, displayName: self.user!.firstName + " " + self.user!.lastName)
        let otherSender = Sender(senderId: "123", displayName: "Mary")
        
        messagesRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error retrieving details")
            } else {
                for document in querySnapshot!.documents {

                    let data = document.data()

                    let senderId = data["fromId"] as! String

                    let sender = senderId == self.user!.uid ? currSender : otherSender

                    let message = Message(
                        sender: sender,
                        messageId: UUID().uuidString,
                        sentDate: (data["timestamp"] as! Timestamp).dateValue(),
                        kind: .text(data["text"] as! String))

                    //messages.append(message)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let chatVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.chatViewController) as! ChatViewController
                
                
                chatVC.title = matchedPartnerFullName
                chatVC.user = self.user
                chatVC.currSender = currSender
                chatVC.messages = messages
                chatVC.chatUid = chatUid!
                chatVC.matchedPartnerUid = matchedPartnerUid
                
                // Push the next viewcontroller onto the navigation stack after everything
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            }
        }
}
*/
