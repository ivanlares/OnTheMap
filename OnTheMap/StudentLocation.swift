//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by ivan lares on 1/13/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

struct StudentLocation{
    
    var objectId: String
    var latitude: Float
    var longitude: Float
    var mediaUrl: String
    var firstName: String
    var lastName: String
    var mapString: String
    var uniqueKey: String
    
    init?(dictionary: [String:Any]) {
        guard
            let objectId = dictionary[StudentConstants.Keys.objectId] as? String,
            let latitude = dictionary[StudentConstants.Keys.latitude] as? Float,
            let longitude = dictionary[StudentConstants.Keys.longitude] as? Float,
            let mediaUrl = dictionary[StudentConstants.Keys.mediaUrl] as? String,
            let firstName = dictionary[StudentConstants.Keys.firstName] as? String,
            let lastName = dictionary[StudentConstants.Keys.lastName] as? String,
            let mapString = dictionary[StudentConstants.Keys.mapString] as? String,
            let uniqueKey = dictionary[StudentConstants.Keys.uniqueKey] as? String
            else { return nil }
        
        self.objectId = objectId
        self.latitude = latitude
        self.longitude = longitude
        self.mediaUrl = mediaUrl
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.uniqueKey = uniqueKey
    }
    
}
