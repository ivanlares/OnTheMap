//
//  MKMapView+Extension.swift
//  OnTheMap
//
//  Created by ivan lares on 4/3/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import MapKit

extension MKMapView{
    func zoomIn(coordinate: CLLocationCoordinate2D, withLevel level:CLLocationDistance = 10000){
        let camera =
            MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: level)
        self.setCamera(camera, animated: true)
    }
}
