//
//  NotificationsTableViewCell.swift
//  LinkUs
//
//  Created by macos on 28/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import SDWebImage
import MessageKit

class NotificationsTableViewCell: UITableViewCell {
    
    
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBOutlet var categoryPhoto: UIImageView!
    
    @IBOutlet var message: UILabel!
    
    @IBOutlet var date: UILabel!
    
    static let identifier = "NotificationsTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "NotificationsTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: MyNotification) {
        
        // To make the imageview circular with a border
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2.0
        
        let path = "images/\(model.byUserUid)_profile_picture.png"
        
        // Setting profile photo image
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            print("fetching photo url from storage for notifications tableviewcell")
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    strongSelf.profilePhoto.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get download url: \(error)")
                
            }
        }
        
        // Setting the date
        let dateFormatter = MessageKitDateFormatter.shared
        date.text = dateFormatter.string(from: model.date)
        
        // Setting the message and category photo
        switch model.category {
        case "upvote":
            categoryPhoto.image = UIImage(systemName: "hand.thumbsup.fill")
            categoryPhoto.tintColor = .systemGreen
            message.text = "\(model.byUserFullName) has upvoted your forum post!"
            
        case "downvote":
            categoryPhoto.image = UIImage(systemName: "hand.thumbsdown.fill")
            categoryPhoto.tintColor = .systemRed
            message.text = "\(model.byUserFullName) has downvoted your forum post"
            
        case "reply":
            categoryPhoto.image = UIImage(systemName: "ellipses.bubble")
            categoryPhoto.tintColor = .darkText
            message.text = "\(model.byUserFullName) has replied to your forum post!"
            
        case "newApplication":
            categoryPhoto.image = UIImage(systemName: "doc.text")
            categoryPhoto.tintColor = .darkText
            message.text = "You have received a new appllication from \(model.byUserFullName) in your inbox!"
            
        case "match":
            categoryPhoto.image = UIImage(named: "matched")
            message.text = "You have successfully been matched with \(model.byUserFullName)!"
            
        case "markComplete":
            categoryPhoto.image = UIImage(systemName: "checkmark")
            categoryPhoto.tintColor = .systemGreen
            message.text = "\(model.byUserFullName) has marked your application as completed! Proceed to leave a review!"
            
        case "review":
            categoryPhoto.image = UIImage(systemName: "star.fill")
            categoryPhoto.tintColor = .systemYellow
            message.text = "\(model.byUserFullName) has left a review for you!"
            
        default:
            print("Notifications category error")
        }
        
        
    }
    
}
