//
//  ParseClient.swift
//  OnTheMap
//
//  Created by ivan lares on 1/11/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

class ParseClient{
    
    static let sharedInstance = ParseClient()
    
    private init() {}
    
    // MARK: Request Methods 
  
    func performGetMethod(withQueryItems queryItems:[URLQueryItem], completionHandler: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        // setup url request
        guard let queryString = JsonHelper.query(withItems: queryItems),
            let url = URL(string: Url.base + queryString) else {
            print("\nUnable to create url: \(#line)")
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(Constants.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // perform request 
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let data = data {
                ParseClient.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NSError(domain: "com.laresivan.onthemap", code: 0, userInfo: nil))
                return
            }
        }
        
        task.resume()
    }
    
    func performPost(withJsonBody body: [String:Any], completionHandler: @escaping(_ result: AnyObject?, _ error: Error?) -> Void){
        // configure request
        let urlString = Url.base
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Test method with api keys
        // use API key in Constants struct
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // append serialized json body to request
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        }
        catch let error as NSError {
            completionHandler(nil, error)
            return
        }
        
        // run request
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let data = data {
                ParseClient.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NSError(domain: "com.laresivan.onthemap", code: 0, userInfo: nil))
                return
            }
        }
        
        task.resume()
    }
    
    // MARK: Convenience Methods
    
    func getStudentLocations(completionHandler: @escaping (_ results: Any?, _ error: Error?) -> Void){
        let queries =
            [URLQueryItem(name:QueryParameters.order,value:QueryValues.order), URLQueryItem(name:QueryParameters.limit, value:String(QueryValues.limit))]
        performGetMethod(withQueryItems: queries){
            (data, error) in
            completionHandler(data, error)
        }
    }
    
    func post(studentData: [String:Any], completion: @escaping (_ objectId: String?, _ error: Error?) -> Void){
        // perform post method with student data
        performPost(withJsonBody: studentData){ result, error in
            // Error handling
            guard error == nil else {
                completion(nil, error)
                return
            }
            // check if the server returned an error
            if let errorString = result?["error"] as? String, let errorCode = result?["code"] as? Int{
                completion(nil, NSError(domain: "com.laresivan.onthemap", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            // used when there is an error accessing the results
            let unexpectedError = NSError(domain: "Unexpected", code: 0, userInfo: nil)
            
            // get object id
            if let objectId = result?["objectId"] as? String{
                completion(objectId, nil)
            } else {
                completion(nil, unexpectedError)
            }
        }
    }
    
    func getStudents(withObjectIdQuery query: URLQueryItem, completion: @escaping (_ students: Any?, _ error: Error?) -> Void){
        performGetMethod(withQueryItems: [query]){
            (results, error) in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            guard let results = results else {
                completion(nil, ParseApiError.unableToFetchData)
                return
            }
            completion(results, nil)
        }
    }
    
    // MARK: Helper
    
    class func parse(jsonData: Data, completionHandler: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        var parsedResult: Any? = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
        }
        catch let error as NSError {
            completionHandler(nil, error)
        }
        
        completionHandler(parsedResult as AnyObject?, nil)
    }
    
}
