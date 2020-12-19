//
//  MSExpertReviewPageViewController.swift
//  LinkUs
//
//  Created by macos on 16/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Cosmos

class MSExpertReviewPageViewController: UIViewController {
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var rating: CosmosView!
    
    @IBOutlet weak var feedbackTextView: UITextView!
    
    var reviewClicked: Review?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy, h:mm aa"
        //dateFormatter.dateFormat = "MMM d h:mm a"
        
        userFullName.text = reviewClicked!.userFullName
        date.text = dateFormatter.string(from: reviewClicked!.date!)
        feedbackTextView.text = reviewClicked!.feedback
        
        rating.rating = reviewClicked!.ratings!
        self.rating.settings.fillMode = .half
        self.rating.settings.updateOnTouch = false
        self.rating.settings.textColor = .darkText
        self.rating.settings.textMargin = 10
        self.rating.text = String(format: "%.2f", self.rating.rating) + " stars"
        
        // To make the imageview circular with a border
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.lightGray.cgColor
        userImage.layer.cornerRadius = userImage.frame.size.width / 2.0
        
        let path = "images/\(reviewClicked!.userUid!)_profile_picture.png"
        
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
