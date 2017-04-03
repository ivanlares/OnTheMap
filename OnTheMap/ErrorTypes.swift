//
//  ErrorHelper.swift
//  OnTheMap
//
//  Created by ivan lares on 2/22/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

enum UserError: Error{
    case missingWebsite
    case missingUsername
    case missingLocation
}
enum ApplicationError: Error{
    case missingUserInfo
}
