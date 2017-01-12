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
    
    // MARK: - Target Action 
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance.logout()
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
