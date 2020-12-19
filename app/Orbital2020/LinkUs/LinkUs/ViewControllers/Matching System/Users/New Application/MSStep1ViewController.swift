//
//  MatchingSystemStep1ViewController.swift
//  LinkUs
//
//  Created by macos on 29/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit

class MSStep1ViewController: UIViewController {

    @IBOutlet weak var selectCategory: UIButton!
    
    @IBOutlet weak var selectOccupation: UIButton!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var occupationTableView: UITableView!
    
    
    var applicationForm: MSUserApplication?
    
    
    let categoryList = [MSCategoryOption.UniCourse, MSCategoryOption.WorkingLife, MSCategoryOption.Career]
    let occupationList = [MSOccupationOption.Studying, MSOccupationOption.Employed, MSOccupationOption.Unemployed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // Disable the next button initially
        nextButton.isEnabled = false
        
        occupationTableView.delegate = self
        occupationTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        // Hide both of the menu selection initially
        categoryTableView.isHidden = true
        occupationTableView.isHidden = true
        
        // Create a new MSUserApplication form
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            let userFullName = homeTabBarController.user!.firstName + " " +  homeTabBarController.user!.lastName
            
            applicationForm = MSUserApplication(userUid: homeTabBarController.user!.uid, userFullName: userFullName)
            
        }
 
    }
    
    @IBAction func selectCategoryTapped(_ sender: Any) {
        
        // Show the options
        toggleMenu(hidden: categoryTableView.isHidden, tableView: categoryTableView)
        
    }
    
    
    @IBAction func selectOccupationTapped(_ sender: Any) {
        
        // Show the options
        toggleMenu(hidden: occupationTableView.isHidden, tableView: occupationTableView)
        
    }
    
    func toggleMenu(hidden: Bool, tableView: UITableView) {
        
        if hidden {
            UIView.animate(withDuration: 0.3) {
                tableView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                tableView.isHidden = true
            }
        }
    }
    
    // Enable the next button only after user filled in all fields
    func checkNextButton() {
        if selectCategory.currentTitle != "Select a category:" && selectOccupation.currentTitle != "Select an option:" {
            
            nextButton.isEnabled = true
            
        } else {
            
            nextButton.isEnabled = false
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? MSStep2ViewController {
            
            destinationVC.applicationForm = self.applicationForm
            
        }
    }
    
}


// MARK: - TableView Delegate and DataSource methods

extension MSStep1ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        switch tableView {
        case categoryTableView:
            rows = categoryList.count
            
        case occupationTableView:
            rows = occupationList.count
            
        default:
            print("Something went wrong in numOfRowsInSection")
            
        }
        return rows
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        switch tableView {
        case categoryTableView:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
            
            cell.textLabel?.text = categoryList[indexPath.row].description
            
        case occupationTableView:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "occupationCell", for: indexPath)
            
            cell.textLabel?.text = occupationList[indexPath.row].description
            
        default:
            print("Something went wrong in cellForRowAt")
            
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case categoryTableView:
            
            // Update the text on the Select Category button to the selected option
            selectCategory.setTitle(categoryList[indexPath.row].description, for: .normal)
            
            // Hides the menu of options when user chooses an option
            toggleMenu(hidden: categoryTableView.isHidden, tableView: categoryTableView)
            
            // Update the application form details
            applicationForm?.category = categoryList[indexPath.row]
            
            // Checks if all categories are filled in to enable the Next button
            checkNextButton()
            
        case occupationTableView:
            
            selectOccupation.setTitle(occupationList[indexPath.row].description, for: .normal)
            
            toggleMenu(hidden: occupationTableView.isHidden, tableView: occupationTableView)
            
            applicationForm?.occupation = occupationList[indexPath.row]
            
            checkNextButton()
            
        default:
            print("Something went wrong in didSelectRowAt")
        }
        
    }
    
}


