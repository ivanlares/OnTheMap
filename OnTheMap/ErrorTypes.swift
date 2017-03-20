//
//  ErrorHelper.swift
//  OnTheMap
//
//  Created by ivan lares on 2/22/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

// UdacityApiError
enum LoginError: Error {
    case unableToRetrieveUserData
}
enum ParseApiError: Error{
    //case missingStudentLocation
    //case missingStudentWebsite
    //case missingStudentData
    case unableToFetchData
}
enum NetworkingError: Error{
    case parsingError
    case unexpectedData
}
enum UserError: Error{
    case missingWebsite
    case missingUsername
    case missingLocation
}
enum ApplicationError: Error{
    case missingUserInfo
}
