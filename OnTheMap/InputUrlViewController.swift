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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var locationData: LocationData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        websiteTextField.delegate = self
    }

    @IBAction func didPressSubmit(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        submit(){ error in
            performOnMain {
                self.activityIndicator.stopAnimating()
                if let error = error{
                    // Show alert
                    print((error, #line))
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    func submit(completion:@escaping (Error?)->Void){
        guard let studentJsonBody = buildStudentJsonBody() else {
            completion(nil)
            return
        }
        guard let objectIdQuery = self.objectIdQuery() else {
            completion(nil)
            return
        }
        
        ParseClient.sharedInstance.getStudents(withObjectIdQuery: objectIdQuery){
            (results, error) in
            guard error == nil else {
                completion(error)
                return
            }
            if let students = self.convert(studentData: results), let student = students.first{
                // there are students with unique key
                // use put method to update student data
                ParseClient.sharedInstance.performPut(withJsonBody: studentJsonBody, objectId: student.objectId){
                    (results, error) in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            } else {
                // no student locations with unique key
                // post new student location
                ParseClient.sharedInstance.post(studentData: studentJsonBody){
                    (_, error) in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            }
        }
    }
    
    /**
        This method builds the student location json body to be posted to the Parse Api.
        An alert will display any errors.
     
        - returns: Returns dictionary representing student location to be posted to Parse Api. Nil can be returned.
    */
    func buildStudentJsonBody() -> [String:Any]?{
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
    
    /**
        Builds uniqueId query to be used in Parse Api call.
     
        - returns: URLQueryItem or nil
    */
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

extension InputUrlViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
