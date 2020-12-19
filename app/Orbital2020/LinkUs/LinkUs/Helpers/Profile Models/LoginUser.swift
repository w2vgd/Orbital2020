//
//  User.swift
//  LinkUs
//
//  Created by macos on 25/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

struct LoginUser {
    
    var firstName: String
    var lastName: String
    
    // Profile Picture
    var profilePictureFileName: String {
        // uid_profile_picutre.png
        return "\(uid)_profile_picture.png"
    }
    
    // Properties that cannot be changed
    var gender: String
    var email: String
    var dob: String
    var uid: String
    var creationDate: String
    
    // Optional type as user do not need to fill in these info yet upon signing up
    var favHobby: String?
    var occupation: String?
    var bio: String?
    
    // Initialized to false when user first signs up for an account
    var hasApplication: Bool = false
    
    // For experts
    var specializations: [String]?
    var applicationsUidList: [String]? // uid of applications sent to the expert
    var stopReceiveApplications: Bool = false //default to false to receive applications
    
    // List of available chats of the current user
    var chatsList: ChatsList?
    
    // For badges
    var totalUpvoteCount: Int
    var totalDownvoteCount: Int
    var totalForumPostCount: Int
    var totalForumReplyCount: Int
    
    // For reports
    var totalReportCount: Int
    
    // For ratings
    var totalRatings: Double
    var totalReviews: Int
}
