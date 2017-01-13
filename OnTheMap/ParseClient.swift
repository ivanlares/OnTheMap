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
  
    func performGetMethod(withQuery query:[String:Any], completionHandler: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        // setup url request
        guard let url = URL(string: Url.base + escapedParameters(parameters: query)) else {
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
                ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NSError(domain: "com.laresivan.onthemap", code: 0, userInfo: nil))
                return
            }
        }
        
        task.resume()
    }
    
    // MARK: Convenience Methods
    
    func getStudentLocations(completionHandler: @escaping (_ results: Any?, _ error: Error?) -> Void){
        let queryItems:[String:Any] =
            [QueryParameters.order:QueryValues.order,
             QueryParameters.limit:QueryValues.limit]
        
        performGetMethod(withQuery: queryItems){
            (data, error) in
            completionHandler(data, error)
        }
    }
    
    // MARK: Helper
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) {
        var parsedResult: Any? = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        }
        catch let error as NSError {
            completionHandler(nil, error)
        }
        
        completionHandler(parsedResult as AnyObject?, nil)
    }
    
    /**Given a dictionary of parameters,
     convert to a string for a url */
    func escapedParameters(parameters: [String : Any]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            //Make sure that it is a string value
            let stringValue = "\(value)"
            //Escape it
    
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            //Replace spaces with '+'
            let replaceSpaceValue = escapedValue!.replacingOccurrences(of: " ", with: "+")
            //Append it
            urlVars += [key + "=" + "\(replaceSpaceValue)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
}
