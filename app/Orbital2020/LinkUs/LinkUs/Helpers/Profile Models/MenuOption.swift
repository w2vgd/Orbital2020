//
//  MenuOption.swift
//  LinkUs
//
//  Created by macos on 26/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// MenuOption class for the SideMenu in HomeViewController
enum MenuOption: Int {
    
    case Settings
    
    var description: String {
        
        switch self {

        case .Settings:
            return "Settings"
        
        // can add more cases next time if needed

        }
        
    }
    
}
