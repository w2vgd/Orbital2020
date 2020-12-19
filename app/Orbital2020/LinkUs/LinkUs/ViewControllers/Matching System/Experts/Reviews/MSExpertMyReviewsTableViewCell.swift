//
//  MSExpertMyReviewsTableViewCell.swift
//  LinkUs
//
//  Created by macos on 16/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class MSExpertMyReviewsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var ratings: CosmosView!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var shortenedFeedback: UILabel!
    
    static let identifier = "MSExpertMyReviewsTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MSExpertMyReviewsTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: Review) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d h:mm a"
        
        self.userFullName.text = "Reviewed By: " + model.userFullName!
        self.date.text = "Reviewed on: " + dateFormatter.string(from: model.date!)
        self.ratings.rating = model.ratings!
        self.shortenedFeedback.text = model.shortenedFeedback!
        
        // To make the imageview circular with a border
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.cornerRadius = userImage.frame.size.width / 2.0
        
        
        let path = "images/\(model.userUid!)_profile_picture.png"
        
        /* Might need to fix because this keeps downloading url from firebase */
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    strongSelf.userImage.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get download url: \(error)")
            }
        }
        
    }
    
}
