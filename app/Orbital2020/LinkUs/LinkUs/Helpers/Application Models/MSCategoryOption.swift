//
//  MSCategory.swift
//  LinkUs
//
//  Created by macos on 30/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// MSCategoryOption class for MSStep1ViewController & MSExpertSpecializationViewController
enum MSCategoryOption: Int, CustomStringConvertible {
    
    case UniCourse, WorkingLife, Career
    
    var description: String {
        
        switch self {
        case .UniCourse:
            return "University Course"
        case .WorkingLife:
            return "Working Life"
        case .Career:
            return "Career Opportunities"
        }
        
        // can add more cases next time if needed
        
    }
    
}
