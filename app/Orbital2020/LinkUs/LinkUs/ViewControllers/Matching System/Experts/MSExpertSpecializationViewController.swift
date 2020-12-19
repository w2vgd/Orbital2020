//
//  MSExpertSpecializationViewController.swift
//  LinkUs
//
//  Created by macos on 1/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class MSExpertSpecializationViewController: UIViewController {
    
    @IBOutlet weak var mySpecializations: UILabel!
    
    @IBOutlet weak var specializationTableView: UITableView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    var user: LoginUser?
    
    // Specialization options
    let specializationList = [MSCategoryOption.UniCourse, MSCategoryOption.WorkingLife, MSCategoryOption.Career]
    
    var selectedOptions = [MSCategoryOption]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        specializationTableView.delegate = self
        specializationTableView.dataSource = self
        
        specializationTableView.isEditing = true
        specializationTableView.allowsMultipleSelectionDuringEditing = true
        
        Utilities.styleBlueBorderButton(updateButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateSpecializations()
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        // Update the database after expert is done updating specializations
        
        var specializationsList = [String]()
        for option in self.selectedOptions {
            specializationsList.append(option.description)
        }
        
        FirebaseFirestoreManager.shared.updateSpecializations(for: user!.uid, specializationsList: specializationsList) { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            // Update user variable
            strongSelf.user!.specializations = specializationsList
            
            // Update the user variable in homeTBC
            if let homeTabBarController = strongSelf.tabBarController as? HomeTabBarController {
                
                homeTabBarController.user = strongSelf.user
                
            }
        }
    }
    
    func updateSelectedOptions(tableView: UITableView, indexPath: IndexPath) {
        
        selectedOptions.removeAll()
        
        if let arr = tableView.indexPathsForSelectedRows {
            
            for index in arr {
                
                selectedOptions.append(specializationList[index.row])
                
            }
            
        }
    }
    
    func updateSpecializations() {
        
        mySpecializations.text = ""
        
        if let specializations = user?.specializations {
            for specialization in specializations {
                mySpecializations.text! += specialization + "\n"
            }
        }
        
        if mySpecializations.text?.isEmpty == false {
            mySpecializations.text!.removeLast()
        }
    }

}

// MARK: - TableView Delegate Methods

extension MSExpertSpecializationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return specializationList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "specializationCell", for: indexPath)
        
        cell.textLabel?.text = specializationList[indexPath.row].description
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        updateSelectedOptions(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        updateSelectedOptions(tableView: tableView, indexPath: indexPath)
        
    }
    

}



