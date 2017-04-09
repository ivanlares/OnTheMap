//
//  SettingsTableViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 4/8/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var deletionIndicator: UIActivityIndicatorView!

    // MARK: Target Action 
    
    @IBAction func didPressDeleteAll(_ sender: UIButton) {
        deleteAllPins()
    }
 
    // MARK: Methods
    
    func deleteAllPins(){
        deletionIndicator.startAnimating()
        
        ParseClient.sharedInstance.getStudents(withObjectIdQuery: objectIdQuery()!){ results, error in
            guard let students = StudentLocation.convert(studentData: results), !students.isEmpty else {
                // stop activity indicator
                performOnMain {
                    self.deletionIndicator.stopAnimating()
                }
                return
            }
            
            var duplicateLocationObjects = [String]()
            for student in students{
                if student.uniqueKey == SharedData.sharedInstance.currentUser!.userKey{
                    duplicateLocationObjects.append(student.objectId)
                }
            }
            
            let max = students.count<50 ? students.count : 50
            var jsonBody = ["requests" : [[String:Any]]()]
            for i in stride(from: 0, to: max, by: 1){
                jsonBody["requests"]?.append([
                    "method":"DELETE",
                    "path":"/parse/classes/StudentLocation/\(students[i].objectId)"
                    ])
            }
    
             ParseClient.sharedInstance.performBatchOperation(withJsonBody: jsonBody){ results, error in
                performOnMain {
                    self.deletionIndicator.stopAnimating()

                    if let error = error{
                        let errorAlert = UIAlertController.alert(withTitle: "Error", message: error.localizedDescription)
                        self.present(errorAlert, animated: true)
                    }
                }
             }
        }
    }
    
    func objectIdQuery() -> URLQueryItem?{
        guard let uniqueKey = SharedData.sharedInstance.currentUser?.userKey else {
            return nil
        }
        let queryObject = ["uniqueKey": uniqueKey]
        guard let queryValue =
            try? JsonHelper.convert(object: queryObject) else {
                return nil
        }
        let objectIdQuery =
            URLQueryItem(name: ParseClient.QueryParameters.whereKey, value: queryValue)
        return objectIdQuery
    }

}
