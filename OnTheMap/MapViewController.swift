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

class MapViewController: UIViewController, StudentDataDownloader{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        ParseClient.sharedInstance.getStudentLocations(){
            (data, error) in
            guard error != nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let studentData = self.convert(studentData: data){
                SharedData.sharedInstance.studentLocations = studentData
            }
            
        }
        
    }
    
    // MARK: - Target Action
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance.logout()
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
