//
//  InputLocationViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/15/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit
import CoreLocation

typealias LocationData =
    (coordinate:CLLocationCoordinate2D, description:String)

class InputLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }
    
    // MARK: Target Action 
    
    @IBAction func didPressNext(_ sender: UIButton) {
        guard let locationString = locationTextField.text else {
            return
        }
        
        find(location: locationString){ (coordinate, error) in
            // Handle error
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let coordinate = coordinate else {
                print("Unexpected error, unable to find location")
                return
            }
            
            // perform segue
            performOnMain {
                self.performSegue(withIdentifier: "SubmitSegue", sender: (coordinate: coordinate, location: locationString))
            }
        }
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    func find(location: String, completionHandler: @escaping (_ coordinate:CLLocationCoordinate2D?, _ error: Error?) -> Void){
        // geocode with location string
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location){ placemarks,error in
            // Error handling
            guard error == nil else{
                completionHandler(nil, error)
                return
            }
            let noMatchesError =
                NSError(domain: "com.laresivan.onthemap", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to find any matches"])
            guard let placemarks = placemarks, !placemarks.isEmpty else {
                completionHandler(nil, noMatchesError)
                return
            }
            guard let placemark = placemarks.first else{
                completionHandler(nil, noMatchesError)
                return 
            }
            guard let location = placemark.location else{
                completionHandler(nil, noMatchesError)
                return
            }
            
            // retrive coordinates of location
            completionHandler(location.coordinate, nil)
        }
    }
    
     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let data = sender as? LocationData else{
          return
        }

        if let inputLocationController = segue.destination as? InputUrlViewController{
            inputLocationController.locationData = data
        }
     }
}

extension InputLocationViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else {
            return true
        }
        let newString = currentText.replacingCharacters(in: range, with: string)
        
        if newString.isEmpty{
            print("newString is empty")
            nextButton.isEnabled = false
            nextButton.alpha = 0.5
        } else {
            print("newString is not empty")
            nextButton.isEnabled = true
            nextButton.alpha = 1
        }
        return true
    }
}
