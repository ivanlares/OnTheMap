//
//  MapViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/11/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        ParseClient.sharedInstance.getStudentLocations(){
            (data, error) in
            guard error != nil else {
                print(error!.localizedDescription)
                return
            }
            
            // TODO: abstract away code that converts json data into student array
            // this task will be used in diffrent classes
            // create helper class 
            // this shouldn't be done in client class because 
            // it's coupling the model with the client
            
            guard let data = data as? [String: Any] else {
                return
            }
            
            guard let studentDataArray = data[StudentConstants.Keys.retults] as? [[String: Any]] else {
                return
            }
            
            var students = [StudentLocation]()
            
            for studentDic in studentDataArray{
                if let student = StudentLocation(dictionary: studentDic){
                    students.append(student)
                }
            }
            
            for i in students {
                print(i)
            }
            
        }
        
    }
    
    // MARK: - Target Action
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance.logout()
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
