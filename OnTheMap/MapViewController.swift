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
        super.viewDidLoad()
        
        ParseClient.sharedInstance.getStudentLocations(){
            (data, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let studentData = self.convert(studentData: data){
                performOnMain(){
                    SharedData.sharedInstance.studentLocations = studentData
                    self.addAnnotationsToMap()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addAnnotationsToMap()
    }
    
    // MARK: - Target Action
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        UdacityClient.sharedInstance.logout()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func didPressRefresh(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func didPressAddPin(_ sender: UIBarButtonItem) {
    }
    
    
    // MARK: Helper
    
    /// removes current annotations and
    /// re-inserts annotations
    func addAnnotationsToMap(){
        guard !SharedData.sharedInstance.studentLocations.isEmpty else {
            return
        }
        
        var annotations = [MKAnnotation]()
        for student in SharedData.sharedInstance.studentLocations{
            let location =
                CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude!), longitude: CLLocationDegrees(student.longitude!))
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaUrl
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
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
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else { pinView!.annotation = annotation }
        
        return pinView
    }
}
