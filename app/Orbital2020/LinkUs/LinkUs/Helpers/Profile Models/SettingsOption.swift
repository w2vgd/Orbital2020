//
//  SettingsOption.swift
//  LinkUs
//
//  Created by macos on 27/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// SettingsOption class for SettingsViewController
enum SettingsOption: Int {
    
    case EditInfo, EditPhoto
    
    var description: String {
        
        switch self {
            
        case .EditInfo:
            return "Edit Profile Information"
            
        case .EditPhoto:
            return "Edit Profile Photo"
        }
        
        // can add more cases next time if needed
        
    }
    
}
