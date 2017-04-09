//
//  ParseClientConstants.swift
//  OnTheMap
//
//  Created by ivan lares on 1/11/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

extension ParseClient{
    
    struct Constants{
        static let applicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Url{
        static let base =
            "https://parse.udacity.com/parse/classes/StudentLocation"
        static let studentLocationPath = "/parse/classes/StudentLocation"
        static let batchBase = "https://parse.udacity.com/parse/batch"
    }
    
    struct QueryParameters{
        static let order = "order"
        static let limit = "limit"
        static let whereKey = "where"
    }
    
    struct QueryValues{
        static let order = "-updatedAt,-createdAt"
        static let limit = 100
    }
    
}
