//
//  MSOccupationOption.swift
//  LinkUs
//
//  Created by macos on 30/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// MSOccupationOption class for MSStep1ViewController
enum MSOccupationOption: Int {
    
    case Studying, Employed, Unemployed
    
    var description: String {
        
        switch self {
        case .Studying:
            return "Studying"
        case .Employed:
            return "Employed"
        case .Unemployed:
            return "Unemployed"
            
        // can add more cases next time if needed
            
        }
        
    }
    
}
