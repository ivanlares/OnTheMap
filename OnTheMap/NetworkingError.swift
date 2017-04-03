//
//  NetworkingError.swift
//  OnTheMap
//
//  Created by ivan lares on 4/2/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

enum NetworkingError: Error{
    case parsingError
    case unexpectedData
    case unableToRetrieveData
    case serverError(String)
}

extension NetworkingError: LocalizedError{
    var errorDescription: String?{
        get{
            switch self{
            case .serverError(let message): return message
            default: return "Unable to retrieve data."
            }
        }
    }
}
