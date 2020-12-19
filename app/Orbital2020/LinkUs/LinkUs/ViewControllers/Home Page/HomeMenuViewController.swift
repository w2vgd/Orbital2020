//
//  HomeViewMenuController.swift
//  LinkUs
//
//  Created by macos on 24/5/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import SideMenu

class HomeMenuViewController: UITableViewController {
    
    // Menu items
    let items = [MenuOption.Settings]
    
    let darkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpTableElements()

    }
    
    func setUpTableElements() {
        
        // Make the menu have a dark background
        //tableView.backgroundColor = darkColor
        
        // Adjust the row height of each option
        tableView.rowHeight = 60
        
        // Remove the extra separator lines below the options
        tableView.tableFooterView = UIView()
        
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].description
        
        // change text color to white against dark background
        //cell.textLabel?.textColor = .white
        
        // change text background color to dark color
        //cell.backgroundColor = darkColor
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the menu item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        // do something after clicking on each menu item
        
        let menuOption = MenuOption(rawValue: indexPath.row)
        didSelectMenuOption(menuOption: menuOption!)
        
    }
    
    func didSelectMenuOption(menuOption: MenuOption) {

        switch menuOption {
        case .Settings:
            
            performSegue(withIdentifier: "sideMenuSegueToSettings", sender: self)
        }
        
    }
    
}
