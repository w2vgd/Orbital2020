//
//  Review.swift
//  LinkUs
//
//  Created by macos on 16/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// To model the list of chats of a user
struct Review {
    
    var reviewUid: String
    var userUid: String?
    var userFullName: String?
    var expertUid: String?
    var ratings: Double?
    var feedback: String?
    var date: Date?
    
    // Shortened version of the feedback to present at expert's MyReviews page
    var shortenedFeedback: String?
    
    
    init(reviewUid: String) {
        self.reviewUid = reviewUid
    }
}
