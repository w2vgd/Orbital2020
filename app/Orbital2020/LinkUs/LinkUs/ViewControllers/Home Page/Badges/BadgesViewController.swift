//
//  BadgesViewController.swift
//  LinkUs
//
//  Created by macos on 14/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class BadgesViewController: UIViewController {
    
    @IBOutlet weak var badgesCollectionView: UICollectionView!
    
    var user: LoginUser?
    
    // Badge list
    var badges = [
        Badge(badgeImage: UIImage(named: "badge1")!, badgeName: "Precious Opinions"),
        Badge(badgeImage: UIImage(named: "badge2")!, badgeName: "Valuable Opinions"),
        Badge(badgeImage: UIImage(named: "badge3")!, badgeName: "Curious Mind"),
        Badge(badgeImage: UIImage(named: "badge4")!, badgeName: "Question Generator"),
        Badge(badgeImage: UIImage(named: "badge5")!, badgeName: "Forum Observer"),
        Badge(badgeImage: UIImage(named: "badge6")!, badgeName: "Community Contributor"),
        Badge(badgeImage: UIImage(named: "badge7")!, badgeName: "Verified Expert")
    ]
    
    // Badge descriptions
    var badgesDescription = [
        "50 Upvotes",
        "100 Upvotes",
        "20 Forum Posts",
        "50 Forum Posts",
        "20 Forum Replies",
        "50 Forum Replies",
        "Verified Expert"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        badgesCollectionView.delegate = self
        badgesCollectionView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
    }

}


// MARK: - Collection View Delegate Methods

extension BadgesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badgeCell", for: indexPath) as! BadgeCollectionViewCell
        
        let badge = badges[indexPath.row]
        
        
        switch indexPath.row {
        case 0: // For 1st badge
            if self.user!.totalUpvoteCount >= 50 { // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 1:  // For 2nd badge
            if self.user!.totalUpvoteCount >= 100 {  // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 2:  // For 3rd badge
            if self.user!.totalForumPostCount >= 20 {  // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 3:  // For 4th badge
            if self.user!.totalForumPostCount >= 50 {  // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 4:  // For 5th badge
            if self.user!.totalForumReplyCount >= 20 {  // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 5:  // For 6th badge
            if self.user!.totalForumReplyCount >= 50 {  // Change to higher number
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        case 6:  // For 7th badge
            if self.user!.totalUpvoteCount >= 1000 {  // For implementing verified expert next time
                cell.setBadge(badge: badge, displayBadge: true)
            } else {
                cell.setBadge(badge: badge, displayBadge: false)
            }
            
        default:
            cell.setBadge(badge: badge, displayBadge: false)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let popTip = SwiftPopTipView()
        popTip.animation = .slide
        popTip.popColor = .lightGray
        popTip.textColor = .darkText
        popTip.dismissTapAnywhere = true
        popTip.message = badgesDescription[indexPath.row]
        popTip.presentPointingAtView(cell!, containerView: collectionView, animated: true)
        
    }
    
    
}

extension BadgesViewController: UICollectionViewDelegateFlowLayout {
    
}
