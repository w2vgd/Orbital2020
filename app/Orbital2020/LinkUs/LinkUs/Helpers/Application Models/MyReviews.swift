//
//  Review.swift
//  LinkUs
//
//  Created by macos on 16/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import Firebase

// To model the list of chats of a user
struct MyReviews {
    
    var reviewsUidList: [String]?
    var reviewsUidToRatingsMap: [String : Double]?
    var reviewsUidToUserUidMap: [String : String]?
    var reviewsUidToUserFullNameMap: [String : String]?
    var reviewsUidToTimestampMap: [String : Timestamp]?
    var reviewsUidToUShortenedFeedbackMap: [String : String]?
    
}
