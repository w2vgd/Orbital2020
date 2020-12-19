//
//  ReportOption.swift
//  LinkUs
//
//  Created by macos on 17/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation

// ReportOption class for choosing category of misconduct in MSUserReportExpertVCand MSExpertReportUserVC
enum ReportOption: Int {
    
    case Spam, Harassment, UseOfProfanity
    case Others
    
    var description: String {
        
        switch self {
        case .Spam:
            return "Spam"
        case .Harassment:
            return "Harassment"
        case .UseOfProfanity:
            return "Use of Profanity"
        case .Others:
            return "Others"
            
        // can add more cases next time if needed
        }
        
    }
    
}
