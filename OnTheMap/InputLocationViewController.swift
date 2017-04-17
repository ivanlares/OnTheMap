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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    enum InputLocationError: LocalizedError{
        case unknownLocation
        case emptyLocation
        
        var errorDescription: String?{
            switch self{
            case .unknownLocation: return "Unable to find location."
            case .emptyLocation: return "Empty location text."
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }
    
    // MARK: Target Action 
    
    @IBAction func didPressNext(_ sender: UIButton) {
        guard let locationString = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !locationString.isEmpty else {
            let errorAlert = UIAlertController.alert(withTitle: "Error", message: InputLocationError.emptyLocation.localizedDescription)
            present(errorAlert, animated: true)
            return
        }
        
        activityIndicator.startAnimating()
        
        find(location: locationString){ (coordinate, error) in
            performOnMain { self.activityIndicator.stopAnimating() }
            
            // Handle error
            guard let coordinate = coordinate, error == nil else {
                let errorAlert =
                    UIAlertController.alert(withTitle: "Geocoding Error", message: error?.localizedDescription ?? InputLocationError.unknownLocation.localizedDescription)
                performOnMain {
                    self.present(errorAlert, animated: true)
                }
                return
            }
            
            // perform segue
            performOnMain {
                self.performSegue(withIdentifier: "SubmitSegue", sender: LocationData(coordinate, locationString))
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
            guard let placemarks = placemarks,
                let placemark = placemarks.first,
                let location = placemark.location else {
                completionHandler(nil, InputLocationError.unknownLocation)
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
            nextButton.isEnabled = false
            nextButton.alpha = 0.5
        } else {
            nextButton.isEnabled = true
            nextButton.alpha = 1
        }
        return true
    }
}
