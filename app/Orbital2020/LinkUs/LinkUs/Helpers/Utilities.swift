//
//  Utilities.swift
//  BasicLogin
//
//  Created by macos on 20/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleBlackBottomLineTextField(_ textField: UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        //textfield.frame.height is equal to 45
        //textfield.frame.width is equal to 220
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 60/255, green: 100/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textField.borderStyle = .none
        
        // Add the line to the text field
        textField.layer.addSublayer(bottomLine)
    }
    
    static func styleRedBottomLineTextField(_ textField: UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.systemRed.cgColor
        
        // Remove border on text field
        textField.borderStyle = .none
        
        // Add the line to the text field
        textField.layer.addSublayer(bottomLine)
    }
    
    static func styleFilledButton(_ button: UIButton) {
        
        // Filled rounded corner style
        //button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1) // original
        button.backgroundColor = UIColor.init(red: 48/255, green: 190/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0   //original 25.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button: UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 1 //original 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func styleViewBadgesButton(_ button: UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 15.0   //original 25.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.tintColor = UIColor.black
    }
    
    static func styleBlueBorderButton(_ button: UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 1 //original 2
        button.layer.borderColor = UIColor.link.cgColor
        button.layer.cornerRadius = 20.0
        button.tintColor = UIColor.link
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    
}
