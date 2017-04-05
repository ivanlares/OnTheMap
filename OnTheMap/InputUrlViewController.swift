//
//  InputUrlViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/15/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit
import MapKit

class InputUrlViewController: UIViewController{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var locationData: LocationData?
    enum InputUrlError: LocalizedError{
        case invalidStudentLocation
        case invalidQuery
        
        var errorDescription: String?{
            switch self{
            case .invalidStudentLocation:
                return "Student location created is invalid."
            case .invalidQuery:
                return "Query built is invalid."
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        websiteTextField.delegate = self
        addPin(withLocation: locationData)
    }

    @IBAction func didPressSubmit(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        submit(){ error in
            performOnMain {
                self.activityIndicator.stopAnimating()

                guard let error = error else {
                    self.dismiss(animated: true)
                    return
                }
                
                let errorAlert = UIAlertController.alert(withTitle: "Error", message: error.localizedDescription)
                self.present(errorAlert, animated: true)
            }
        }
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    func submit(completion:@escaping (Error?)->Void){
        guard let studentJsonBody = buildStudentJsonBody() else {
            completion(InputUrlError.invalidStudentLocation)
            return
        }
        guard let objectIdQuery = self.objectIdQuery() else {
            completion(InputUrlError.invalidQuery)
            return
        }
        
        ParseClient.sharedInstance.getStudents(withObjectIdQuery: objectIdQuery){
            (results, error) in
            guard error == nil else {
                completion(error)
                return
            }
            if let students = StudentLocation.convert(studentData: results), let student = students.first{
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
        guard let mediaUrl = websiteTextField.text,
            !mediaUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
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
    
    func addPin(withLocation location: LocationData?){
        guard let location = location else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = location.description
        mapView.addAnnotation(annotation)
        mapView.zoomIn(coordinate: annotation.coordinate)
    }
    
}

extension InputUrlViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension InputUrlViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else { pinView!.annotation = annotation }
        
        return pinView
    }
}
