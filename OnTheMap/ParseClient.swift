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
                completionHandler(nil, NetworkingError.serverError("Invalid Query"))
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
                JsonHelper.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NetworkingError.unexpectedData)
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
                JsonHelper.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NetworkingError.unableToRetrieveData)
                return
            }
        }
        
        task.resume()
    }
    
    func performPut(withJsonBody body: [String:Any], objectId: String, completionHandler: @escaping(_ result: AnyObject?, _ error: Error?) -> Void){
        guard let url = URL(string: Url.base + "/" + objectId) else {
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(Constants.applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // append serialized json body to request
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        catch let error as NSError {
            completionHandler(nil, error)
            return
        }
        
        // perform request
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            if let data = data {
                JsonHelper.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NetworkingError.unexpectedData)
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
                completion(nil,NetworkingError.serverError(
                    "\(errorString): \(errorCode)"))
                return
            }
            // get object id
            if let objectId = result?["objectId"] as? String{
                completion(objectId, nil)
            } else {
                completion(nil, NetworkingError.unexpectedData)
            }
        }
    }
    
    func getStudents(withObjectIdQuery query: URLQueryItem, completion: @escaping (_ students: Any?, _ error: Error?) -> Void){
        let queries =
            [URLQueryItem(name:QueryParameters.order,value:QueryValues.order), URLQueryItem(name:QueryParameters.limit, value:String(QueryValues.limit)),query]
        performGetMethod(withQueryItems: queries){
            (results, error) in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            guard let results = results else {
                completion(nil, NetworkingError.unableToRetrieveData)
                return
            }
            completion(results, nil)
        }
    }
    
}
