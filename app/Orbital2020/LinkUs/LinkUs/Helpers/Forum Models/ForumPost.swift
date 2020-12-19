//
//  ForumPost.swift
//  LinkUs
//
//  Created by macos on 8/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// To model the original forum post
class ForumPost {
    
    var category: String
    var title: String
    var details: String
    var posterUid: String
    var posterFullName: String
    var postDate: Date
    var forumPostUid: String
    var upvotes: Int
    var downvotes: Int
    
    var upvotedUsersUidList: [String]
    var downvotedUsersUidList: [String]
    
    var replies: [ForumReply]?
    
    init(category: String, title: String, details: String, posterUid: String, posterFullName: String, postDate: Date, forumPostUid: String, upvotes: Int, downvotes: Int, upvotedUsersUidList: [String],downvotedUsersUidList: [String]) {
        self.category = category
        self.title = title
        self.details = details
        self.posterUid = posterUid
        self.posterFullName = posterFullName
        self.postDate = postDate
        self.forumPostUid = forumPostUid
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.upvotedUsersUidList = upvotedUsersUidList
        self.downvotedUsersUidList = downvotedUsersUidList
        
    }
}
