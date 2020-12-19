//
//  MSUserApplication.swift
//  LinkUs
//
//  Created by macos on 30/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// To model an application form of the matching system for a "User"
struct MSUserApplication {
    
    var applicationUid: String?
    var category: MSCategoryOption?
    var occupation: MSOccupationOption?
    var paragraph: String?
    
    // The user who submitted the application
    var userUid: String
    var userFullName: String
    
    // Experts who have received this application
    var expertsUidList: [String]?
    
    // Expert who is matched with user
    var matchedExpertUid: String?
    var matchedExpertFullName: String?
    
    // Status of this application
    var applicationStatus: String?
    
    // Boolean which checks if the user has submitted a review for the matched expert, initially set to false
    var hasUserSubmittedReview: Bool = false
    
    init(userUid: String, userFullName: String) {
        self.userUid = userUid
        self.userFullName = userFullName
    }
    
}

