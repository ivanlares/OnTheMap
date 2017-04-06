//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 4/5/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.sharedInstance.studentLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    // MARK: Table View Delegate 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = SharedData.sharedInstance.studentLocations[indexPath.row]
        UIApplication.shared.open(urlString: student.mediaUrl)
    }
    
    // MARK: Helper
    
    func configure(cell: UITableViewCell, atIndexPath indexPath: IndexPath){
        
        let student = SharedData.sharedInstance.studentLocations[indexPath.row]
        let fullName = "\(student.firstName) \(student.lastName)"
        cell.textLabel?.text = fullName
        cell.detailTextLabel?.text = "\(student.mapString)"
    }

}
