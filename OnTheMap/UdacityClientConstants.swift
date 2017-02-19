//
//  UdacityClientConstants.swift
//  OnTheMap
//
//  Created by ivan lares on 1/8/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

extension UdacityClient{
    
    struct Url {
        static let base = "https://www.udacity.com/api/"
    }
    
    struct JsonKeys {
        static let loginCredentials = "udacity"
        static let username = "username"
        static let password = "password"
        
        static let session = "session"
        static let sessionID = "id"
        static let account = "account"
        static let userKey = "key"

        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
        
        static let error = "error"
        static let status = "status"
    }
    
    struct PathKeys {
        static let session = "session"
        static let users = "users"
    }
    
}
