//
//  InputUrlViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/15/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit
import MapKit

class InputUrlViewController: UIViewController, StudentDataConverter {

    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var locationData: LocationData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        websiteTextField.delegate = self
    }

    @IBAction func didPressSubmit(_ sender: UIButton) {
        submit()
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    func submit(){
        // creates json body for student location
        guard let studentJsonBody = studentJsonBody() else {
            return
        }
        // creates getStudent query
        guard let uniqueKey = SharedData.sharedInstance.currentUser?.userKey else {return}
        let queryObject = ["uniqueKey": uniqueKey]
        guard let queryValue =
            try? JsonHelper.convert(object: queryObject) else {
                return
        }
        let objectIdQuery =
            URLQueryItem(name: ParseClient.QueryParameters.whereKey, value: queryValue)
        
        ParseClient.sharedInstance.getStudents(withObjectIdQuery: objectIdQuery){
            (results, error) in
            guard error == nil else {
                print(error!)
                return
            }
            if let students = self.convert(studentData: results), let student = students.first{
                // there are students with unique key
                // use put method to update student data
                print(student)
            } else {
                // no student locations with unique key
                // post new student location
                ParseClient.sharedInstance.post(studentData: studentJsonBody){
                    (objectId, error) in
                    print((objectId, error?.localizedDescription ?? ""))
                }
            }
        }
    }
    
    func studentJsonBody() -> [String:Any]?{
        guard let mediaUrl = websiteTextField.text else {
            return nil
        }
        guard let lat = locationData?.coordinate.latitude,
            let lon = locationData?.coordinate.longitude,
            let locationDescription = locationData?.description else{
                return nil
        }
        let currentUser = SharedData.sharedInstance.currentUser
        guard let uniqueKey = currentUser?.userKey,
            let firstName = currentUser?.firstName,
            let lastName = currentUser?.lastName else {
                return nil
        }
        let jsonBody: [String:Any] = ["uniqueKey":uniqueKey,
                                      "firstName":firstName,
                                      "lastName":lastName,
                                      "mapString":locationDescription,
                                      "mediaURL":mediaUrl,
                                      "latitude":lat as Double,
                                      "longitude":lon as Double]
        return jsonBody
    }
}

extension InputUrlViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
