//
//  ErrorHelper.swift
//  OnTheMap
//
//  Created by ivan lares on 2/22/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

enum LoginError: Error {
    case unableToRetrieveUserData
}
enum ParseApiError: Error{
    case missingStudentLocation
    case missingStudentWebsite
    case missingStudentData
    case unableToFetchData
}
enum NetworkingError: Error{
    case parsingError
    case unexpectedData
}
