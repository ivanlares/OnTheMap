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
        


    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    func submit(){
        guard let mediaUrl = websiteTextField.text else {
            return
        }
        guard let lat = locationData?.coordinate.latitude,
            let lon = locationData?.coordinate.longitude,
            let locationDescription = locationData?.description else{
            return
        }
        let currentUser = SharedData.sharedInstance.currentUser
        guard let uniqueKey = currentUser?.userKey,
            let firstName = currentUser?.firstName,
            let lastName = currentUser?.lastName else {
            return
        }
        let jsonBody: [String:Any] = ["uniqueKey":uniqueKey,
                                      "firstName":firstName,
                                      "lastName":lastName,
                                      "mapString":locationDescription,
                                      "mediaURL":mediaUrl,
                                      "latitude":lat,
                                      "longitude":lon]
    }

}

extension InputUrlViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
