//
//  ChatViewController.swift
//  LinkUs
//
//  Created by macos on 3/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatViewController: MessagesViewController {
    
    var user: LoginUser?
    
    var currSender: Sender!
    var otherSender: Sender!
    
    private var currSenderPhotoURL: URL?
    private var otherSenderPhotoURL: URL?
    
    var matchedPartnerUid: String!
    var chatUid: String!
    
    var messages = [MessageType]()
    var messageListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpMessageListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        messageListener!.remove()
        print("message listener removed in viewdiddisappear")
    
    }
    
    deinit {
        messageListener?.remove()
        print("deinit of chat vc called")
    }
    
    func setUpElements() {
        
        // Assign delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    func setUpMessageListener() {
        
        // limit to last 20 messages sent between each other
        let db = Firestore.firestore()
        let messagesRef = db.collection("chats").document(chatUid).collection("messages").order(by: "timestamp", descending: true).limit(to: 20)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say the chat will be updated in realtime when the 2 users are talking to eaach other (realtime listener is better than fetching data everytime there is a new message)
        messageListener = messagesRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime messages updates: \(error?.localizedDescription ?? "no error")")
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
        case .added:  // when a text message is added to the database
            let senderId = data["fromId"] as! String
            let sender = senderId == self.user!.uid ? currSender : otherSender
            
            let newMessage = Message(
                    sender: sender!,
                    messageId: UUID().uuidString,
                    sentDate: (data["timestamp"] as! Timestamp).dateValue(),
                    kind: .text(data["text"] as! String))
            
            messages.append(newMessage)
            
            // latest message will be at the bottom
            messages.sort { (msg1, msg2) -> Bool in
                switch msg1.sentDate.compare(msg2.sentDate) {
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
                self.messagesCollectionView.reloadData()
            }
            
            
            
        // not handling .modified and .remove cases
        default:
            break
        }
        
    }
    
}


// MARK: - MessageKit Delegate Methods

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MMM d h:mm a"  //E.g. Jun 5 1:11 AM
        
        let dateFormatter = MessageKitDateFormatter.shared
        //dateFormatter.configureDateFormatter(for: message.sentDate)
        
        return NSAttributedString(string: dateFormatter.string(from: message.sentDate), attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 5)
    }
    
    
    
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .darkText
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        
        if sender.senderId == currSender.senderId {
            // Show currSender profile photo
            if let currSenderPhotoURL = self.currSenderPhotoURL {
                avatarView.sd_setImage(with: currSenderPhotoURL, completed: nil)
                
            } else {
                // fetch URL
                // currSender's profile image path
                let path = "images/" + self.user!.profilePictureFileName
                
                FirebaseStorageManager.shared.downloadURL(for: path) { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    switch result {
                    case .success(let url):
                        
                        strongSelf.currSenderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                }
            }
            
        } else {
            // Show otherSender profile photo
            if let otherSenderPhotoURL = self.otherSenderPhotoURL {
                avatarView.sd_setImage(with: otherSenderPhotoURL, completed: nil)
                
            } else {
                // fetch URL
                // otherSender's profile image path
                let path = "images/" + matchedPartnerUid + "_profile_picture.png"
                
                FirebaseStorageManager.shared.downloadURL(for: path) { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    switch result {
                    case .success(let url):
                        
                        strongSelf.otherSenderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                }
            }
        }
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.isEmpty else {
            return
        }
        
        // Need to save message to database here
        let db = Firestore.firestore()
        let messagesRef = db.collection("chats").document(chatUid).collection("messages")
        
        let messageRef = messagesRef.document()
        
        messageRef.setData([
            "fromId" : self.user!.uid,
            "toId" : self.matchedPartnerUid!,
            "text" : text,
            "timestamp" : Timestamp()
        ]) { (error) in
            guard error == nil else {
                //Show error message
                print("Error saving message details!")
                return
            }
            
            // No error in storing application to database
            print("Done storing message details to database")
            
        }
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
        
    }
    
}

