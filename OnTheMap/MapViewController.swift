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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateMapView()
    }

    // MARK: - Target Action
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance.logout(){
            performOnMain {
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func didPressRefresh(_ sender: UIBarButtonItem) {
        updateMapView()
    }
    
    @IBAction func didPressAddPin(_ sender: UIBarButtonItem) {
        let postDataNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostDataNavigationController")
        present(postDataNavigationController, animated: true, completion: nil)
    }
    
    func didPressWebButton(withUrlString urlString: String?){
        UIApplication.shared.open(urlString: urlString)
    }
    
    // MARK: Helper
    
    /** removes current annotations and
        re-inserts annotations
     */
    func updateAnnotations(){
        guard !SharedData.sharedInstance.studentLocations.isEmpty else {
            return
        }
        
        var annotations = [MKAnnotation]()
        for student in SharedData.sharedInstance.studentLocations{
            let location =
                CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude), longitude: CLLocationDegrees(student.longitude))
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaUrl
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    /**
     Downloads new student location data and updates studentLocation array .
     
     - Parameter completion: @escaping (Error?) -> Void
     */
    func downloadStudentData(completion: @escaping (Error?) -> Void){
        ParseClient.sharedInstance.getStudentLocations(){
            (data, error) in
            guard error == nil else {
                completion(error)
                print(error!.localizedDescription)
                return
            }
            
            if let studentData = StudentLocation.convert(studentData: data){
                performOnMain(){
                    SharedData.sharedInstance.studentLocations = studentData
                    completion(nil)
                }
            } else {
                // TODO: return custom error
            }
        }
    }

    /// downloads new data and updates annotations
    func updateMapView(){
        downloadStudentData(){
            error in
            guard error == nil else{
                print(error!)
                return
            }
            performOnMain { self.updateAnnotations() }
        }
    }

}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            
            let webButton = UIButton(type: .custom)
            let webImage = UIImage(named: "web")
            let webHighlightedImage = UIImage(named: "webHighlighted")
            webButton.setImage(webImage, for: .normal)
            webButton.setImage(webHighlightedImage, for: .highlighted)
            webButton.frame =
                CGRect(x: 0, y: 0, width: webImage!.size.width, height: webImage!.size.height)
            pinView?.rightCalloutAccessoryView = webButton
        }
        else { pinView!.annotation = annotation }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            didPressWebButton(withUrlString: view.annotation?.subtitle ?? nil)
        }
    }
}
