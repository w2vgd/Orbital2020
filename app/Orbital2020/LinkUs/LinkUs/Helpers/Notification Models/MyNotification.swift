//
//  MyNotification.swift
//  LinkUs
//
//  Created by macos on 28/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// To model the list of notifications of a user
struct MyNotification {
    
    var byUserUid: String
    var byUserFullName: String
    var category: String
    var date: Date
    
    // For forum notifications
    var forumPostUid: String?
    
    // For application notifications
    var applicationUid: String?
    
    // For review notifications
    var reviewUid: String?
    
}
