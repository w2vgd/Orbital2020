//
//  ForumReply.swift
//  LinkUs
//
//  Created by macos on 9/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// To model a forum post's reply
class ForumReply {
    
    var replyText: String
    var userUid: String
    var userFullName: String
    var replyDate: Date
    var forumReplyUid: String
    var upvotes: Int
    var downvotes: Int
    
    var upvotedUsersUidList: [String]
    var downvotedUsersUidList: [String]
    
    init(replyText: String, userUid: String, userFullName: String, replyDate: Date, forumReplyUid: String, upvotes: Int, downvotes: Int, upvotedUsersUidList: [String],downvotedUsersUidList: [String]) {
        self.replyText = replyText
        self.userUid = userUid
        self.userFullName = userFullName
        self.replyDate = replyDate
        self.forumReplyUid = forumReplyUid
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.upvotedUsersUidList = upvotedUsersUidList
        self.downvotedUsersUidList = downvotedUsersUidList
        
    }
    
}
