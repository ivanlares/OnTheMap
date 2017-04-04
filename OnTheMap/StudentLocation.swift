//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by ivan lares on 1/13/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

/// Representation of Parse `StudentLocation` object
struct StudentLocation{
    
    /// Object id provided by the Parse API
    var objectId: String
    var latitude: Float
    var longitude: Float
    var mediaUrl: String
    var firstName: String
    var lastName: String
    var mapString: String
    /// String value used for identification
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
    
    /**
     Converts student json data into '[StrudentLocation]?'.
     
     - Parameter studentData: student json data of type `Any?`.
     */
    static func convert(studentData: Any?) -> [StudentLocation]?{
        guard let studentData = studentData as? [String: Any] else {
            return nil
        }
        guard let studentDataArray = studentData[StudentConstants.Keys.retults] as? [[String: Any]] else {
            return nil
        }
        
        var students = [StudentLocation]()
        for studentDic in studentDataArray{
            if let student = StudentLocation(dictionary: studentDic){
                students.append(student)
            }
        }
        
        return students
    }
}
