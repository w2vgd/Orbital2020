//
//  ForumReplyTableViewCell.swift
//  LinkUs
//
//  Created by macos on 9/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import MessageKit

// Defined to be a class-only protocol (so as to allow the delegate property of the tableviewcell to be assigned weak)
protocol ForumReplyTableViewCellDelegate: class {
    func replyUpvoteButtonTapped()
    func replyDownvoteButtonTapped()
    func replyReportButtonTapped(reportedForumReply: ForumReply)
}

class ForumReplyTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userFullName: UILabel!
    @IBOutlet var replyDate: UILabel!
    @IBOutlet var replyTextLabel: UILabel!
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var reportButton: UIButton!
    @IBOutlet var upvotes: UILabel!
    @IBOutlet var downvotes: UILabel!
    
    // Assigned weak to prevent a strong reference cycle with the viewcontroller
    weak var delegate: ForumReplyTableViewCellDelegate?
    
    var forumPostClicked: ForumPost?
    var forumReply: ForumReply?
    var user: LoginUser?
    
    static let identifier = "ForumReplyTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ForumReplyTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: ForumReply, user: LoginUser) {
        
        let dateFormatter = MessageKitDateFormatter.shared
        
        self.userFullName.text = "Posted By: " + model.userFullName
        self.replyDate.text = "Posted On: " + dateFormatter.string(from: model.replyDate)
        self.replyTextLabel.text = model.replyText
        self.upvotes.text = "\(model.upvotes)"
        self.downvotes.text = "\(model.downvotes)"
        
        // Disable the upvote/downvote buttons if the user is the original poster or if the user has already voted once before
        if model.userUid == user.uid {
            let upvoteImage = UIImage(systemName: "hand.thumbsup")
            upvoteButton.setImage(upvoteImage, for: .normal)
            upvoteButton.tintColor = .darkText
            
            let downvoteImage = UIImage(systemName: "hand.thumbsdown")
            downvoteButton.setImage(downvoteImage, for: .normal)
            downvoteButton.tintColor = .darkText
            
            upvoteButton.isEnabled = false
            downvoteButton.isEnabled = false
        } else if model.upvotedUsersUidList.contains(user.uid) {
            let image = UIImage(systemName: "hand.thumbsup.fill")
            upvoteButton.setImage(image, for: .normal)
            upvoteButton.tintColor = .systemGreen
            
            upvoteButton.isEnabled = false
            downvoteButton.isEnabled = false
        } else if model.downvotedUsersUidList.contains(user.uid) {
            let image = UIImage(systemName: "hand.thumbsdown.fill")
            downvoteButton.setImage(image, for: .normal)
            downvoteButton.tintColor = .systemRed
            
            downvoteButton.isEnabled = false
            upvoteButton.isEnabled = false
        } else {
            let upvoteImage = UIImage(systemName: "hand.thumbsup")
            upvoteButton.setImage(upvoteImage, for: .normal)
            upvoteButton.tintColor = .darkText
            
            let downvoteImage = UIImage(systemName: "hand.thumbsdown")
            downvoteButton.setImage(downvoteImage, for: .normal)
            downvoteButton.tintColor = .darkText
            
            upvoteButton.isEnabled = true
            downvoteButton.isEnabled = true
        }
        
        
        
        // To make the imageview circular with a border
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.lightGray.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        
        
        let path = "images/\(model.userUid)_profile_picture.png"
        
        /* Might need to fix because this keeps downloading url from firebase */
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            print("fetching photo url from storage for forumreply")
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    strongSelf.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get download url: \(error)")
            }
        }
        
    }
    
    
    @IBAction func replyUpvoteButtonTapped(_ sender: Any) {
        
        print("reply upvote button tapped")
        
        // Updating the ForumReply object here will also update the ForumReply in the array in ForumPageViewController because ForumReply is a class and classes are passed around by reference (unlike structures which are copied when passed around)
        self.forumReply!.upvotes += 1
        self.forumReply!.upvotedUsersUidList.append(self.user!.uid)
        
        FirebaseFirestoreManager.shared.upvoteButtonTappedForForumReply(by: user!.uid, forumPostUid: forumPostClicked!.forumPostUid, forumReply: forumReply!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // Calls the delegate method in ForumPageViewController to reload the tableview
            strongSelf.delegate?.replyUpvoteButtonTapped()
            
            let userFullName = strongSelf.user!.firstName + " " + strongSelf.user!.lastName
            
            FirebaseFirestoreManager.shared.updateTotalUpvoteCount(userUid: strongSelf.user!.uid, userFullName: userFullName, for: strongSelf.forumReply!.userUid, forumPostUid: strongSelf.forumPostClicked!.forumPostUid) { updatedTotalUpvoteCount in
                
                guard updatedTotalUpvoteCount else {
                    return
                }
                
                print("Successfully updated total upvote count")
            }
        }
    }
    
    @IBAction func replyDownvoteButtonTapped(_ sender: Any) {
        
        // Updating the ForumReply object here will also update the ForumReply in the array in ForumPageViewController because ForumReply is a class and classes are passed around by reference (unlike structures which are copied when passed around)
        self.forumReply!.downvotes += 1
        self.forumReply!.downvotedUsersUidList.append(self.user!.uid)
        
        FirebaseFirestoreManager.shared.downvoteButtonTappedForForumReply(by: user!.uid, forumPostUid: forumPostClicked!.forumPostUid, forumReply: forumReply!) { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            guard success else {
                return
            }
            
            // Calls the delegate method in ForumPageViewController to reload the tableview
            strongSelf.delegate?.replyDownvoteButtonTapped()
            
            let userFullName = strongSelf.user!.firstName + " " + strongSelf.user!.lastName
            
            FirebaseFirestoreManager.shared.updateTotalDownvoteCount(userUid: strongSelf.user!.uid, userFullName: userFullName, for: strongSelf.forumReply!.userUid, forumPostUid: strongSelf.forumPostClicked!.forumPostUid) { updatedTotalDownvoteCount in
                
                guard updatedTotalDownvoteCount else {
                    return
                }
                
                print("Successfully updated total downvote count")
            }
        }
    }
    
    @IBAction func replyReportButtonTapped(_ sender: Any) {
        delegate?.replyReportButtonTapped(reportedForumReply: self.forumReply!)
    }
}
