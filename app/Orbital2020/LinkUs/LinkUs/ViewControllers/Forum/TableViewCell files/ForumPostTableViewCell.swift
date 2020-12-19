//
//  ForumPostTableViewCell.swift
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
protocol ForumPostTableViewCellDelegate: class {
    func upvoteButtonTapped()
    func downvoteButtonTapped()
    func replyButtonTapped()
    func reportButtonTapped()
}

class ForumPostTableViewCell: UITableViewCell {
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var posterFullName: UILabel!
    @IBOutlet var postDate: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var upvotes: UILabel!
    @IBOutlet var downvotes: UILabel!
    @IBOutlet var reportButton: UIButton!
    
    // Assigned weak to prevent a strong reference cycle with the viewcontroller
    weak var delegate: ForumPostTableViewCellDelegate?
    
    
    static let identifier = "ForumPostTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ForumPostTableViewCell", bundle: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: ForumPost, user: LoginUser) {
        
        let dateFormatter = MessageKitDateFormatter.shared
        
        self.posterFullName.text = "Posted By: " + model.posterFullName
        self.postDate.text = "Posted On: " + dateFormatter.string(from: model.postDate)
        self.categoryLabel.text = "Category: " + model.category
        self.titleLabel.text = model.title
        self.detailsLabel.text = model.details
        self.upvotes.text = "\(model.upvotes)"
        self.downvotes.text = "\(model.downvotes)"
        
        // Disable the upvote/downvote buttons if the user is the original poster or if the user has already voted once before
        if model.posterUid == user.uid {
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
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 2
        posterImageView.layer.borderColor = UIColor.lightGray.cgColor
        posterImageView.layer.cornerRadius = posterImageView.frame.size.width / 2.0
        
        
        let path = "images/\(model.posterUid)_profile_picture.png"
        
        /* Might need to fix because this keeps downloading url from firebase */
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            print("fetching photo url from storage for forumpost")
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    strongSelf.posterImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get download url: \(error)")
                
            }
        }
    }
    
    @IBAction func upvoteButtonTapped(_ sender: Any) {
        delegate?.upvoteButtonTapped()
    }
    
    @IBAction func downvoteButtonTapped(_ sender: Any) {
        delegate?.downvoteButtonTapped()
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        delegate?.replyButtonTapped()
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        delegate?.reportButtonTapped()
    }
    
}
