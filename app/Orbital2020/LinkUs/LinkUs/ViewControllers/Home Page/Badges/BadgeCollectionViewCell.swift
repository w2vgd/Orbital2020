//
//  BadgeCollectionViewCell.swift
//  LinkUs
//
//  Created by macos on 14/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeImageView: UIImageView!
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    func setBadge(badge: Badge, displayBadge: Bool) {
        
        badgeImageView.image = badge.badgeImage
        badgeImageView.alpha = displayBadge ? 1 : 0.1
        
        badgeLabel.text = badge.badgeName
    }
    
}
