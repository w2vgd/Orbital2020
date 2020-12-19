//
//  MSExpertProceedToChatViewController.swift
//  LinkUs
//
//  Created by macos on 3/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class MSExpertProceedToChatViewController: UIViewController {

    @IBOutlet weak var proceedToChatMessage: UILabel!
    
    @IBOutlet weak var markAsCompleteButton: UIButton!
    
    var applicationClicked: MSUserApplication?
    
    var returnToHomeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        
    }
    
    func setUpElements() {
        
        Utilities.styleBlueBorderButton(markAsCompleteButton)
        
        self.navigationItem.hidesBackButton = true
        
        // Create the Home button
        returnToHomeButton = UIBarButtonItem(image: UIImage(systemName: "house.fill"), style: .done, target: self, action: #selector(returnToHomeButtonTapped))
        
        self.navigationItem.rightBarButtonItem = returnToHomeButton
        
        proceedToChatMessage.text = "You have successfully been matched with \(applicationClicked!.userFullName)!\n Proceed over to the chats section to begin your fruitful discussion!"
        
        
    }
    
    @objc func returnToHomeButtonTapped() {
        
        if let navController = self.navigationController {
            for vc in navController.viewControllers {
                if vc is MSExpertMainPageViewController {
                    navController.popToViewController(vc, animated: true)
                    break
                } else if vc is NotificationsViewController {
                    navController.popToViewController(vc, animated: true)
                    break
                }
            }
        }
        
        //performSegue(withIdentifier: "proceedToChatUnwindSegueToExpertMainPage", sender: self)
        
    }
    
    
    @IBAction func markAsCompleteButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let markCompleteVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertMarkCompleteViewController) as! MSExpertMarkCompleteViewController
        
        markCompleteVC.title = "Mark Complete"
        markCompleteVC.applicationClicked = self.applicationClicked
        
        // Push the next viewcontroller onto the navigation stack after everything is done
        self.navigationController?.pushViewController(markCompleteVC, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? MSExpertMarkCompleteViewController {
            
            destinationVC.applicationClicked = self.applicationClicked
            
        }
        
    }

    

}
