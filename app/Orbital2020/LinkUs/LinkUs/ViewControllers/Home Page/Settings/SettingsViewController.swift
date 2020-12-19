//
//  SettingsViewController.swift
//  LinkUs
//
//  Created by macos on 25/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    // Settings items
    let items = [SettingsOption.EditInfo, SettingsOption.EditPhoto]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableElements()
        
    }
    
    func setUpTableElements() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Adjust the row height of each option
        tableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        tableView.tableFooterView = UIView()
        
    }

    func didSelectSettingsOption(settingsOption: SettingsOption) {
        
        switch settingsOption {
        case .EditInfo:
            
            performSegue(withIdentifier: "settingsSegueToEditProfile", sender: self)
            
        case .EditPhoto:
            
            performSegue(withIdentifier: "settingsSegueToEditPhoto", sender: self)
            
        }
        
    }
    
}


// MARK: - TableView Delegate Methods

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].description
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        let settingsOption = SettingsOption(rawValue: indexPath.row)
        didSelectSettingsOption(settingsOption: settingsOption!)
        
    }
}


