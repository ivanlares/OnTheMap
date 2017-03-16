//
//  JsonHelper.swift
//  OnTheMap
//
//  Created by ivan lares on 3/15/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

struct JsonHelper{
    
    static func convert(object: Any, stringEncoding:String.Encoding = .utf8) throws -> String{
        enum EncodingError: Error{
            case invalidData(Any)
        }
        //Check for valid data
        guard JSONSerialization.isValidJSONObject(object) else{
            throw EncodingError.invalidData(object)
        }
        // convert Swift object into Json object
        var jsonData:Data
        do{
            jsonData = try JSONSerialization.data(withJSONObject: object)
        } catch let error{
            throw error
        }
        guard let encodedString = String(data: jsonData, encoding: stringEncoding) else{
            throw EncodingError.invalidData(jsonData)
        }
        return encodedString
    }
    
    static func query(withItems items: [URLQueryItem], percentEncoded: Bool = true) -> String?{
        let url = NSURLComponents()
        url.queryItems = items
        let queryString = percentEncoded ? url.percentEncodedQuery : url.query
        
        if let queryString = queryString {
            return "?\(queryString)"
        }
        return nil
    }
}
