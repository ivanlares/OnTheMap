//
//  StudentLocationDownloader.swift
//  OnTheMap
//
//  Created by ivan lares on 1/14/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

protocol StudentDataDownloader{
    /**
     Converts student json data into a
     usable array of `StudentLocation` by default.
     
     - Parameter studentData: student json data of type `Any?`.
     */
    func convert(studentData: Any?) -> [StudentLocation]?
}

extension StudentDataDownloader{

    func convert(studentData: Any?) -> [StudentLocation]?{
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
