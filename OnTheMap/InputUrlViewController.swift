//
//  InputUrlViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/15/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit
import MapKit

class InputUrlViewController: UIViewController {

    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var locationData: LocationData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        websiteTextField.delegate = self
    }

    @IBAction func didPressSubmit(_ sender: UIButton) {
        guard let lat = locationData?.coordinate.latitude, let lon = locationData?.coordinate.longitude, let locationDescription = locationData?.description else{
            return
        }
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}

extension InputUrlViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
