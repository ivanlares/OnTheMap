//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by ivan lares on 1/6/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

class UdacityClient{
    
    static let sharedInstance = UdacityClient()
    var sessionId: String?
    var userKey: String?
    
    // MARK: Request Methods 
    
    /**
        Performs an http post request with the following parameters
     
        - Parameter method: `String` representation of the method used in the url request
        - Parameter body: `Dictionary` representation of the json body used in the url request
        - Parameter completionHandler: closure to execute when request is complete
        - Parameter result: the resulting object if request is successful
        - Parameter error: the resulting error if request was unsuccessful
    */
    func performPost(method: String, withJsonBody body: [String:AnyObject], completionHandler: @escaping(_ result: AnyObject?, _ error: Error?) -> Void){
        
        // configure request
        let urlString = Url.base + method
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                UdacityClient.parse(jsonData: data, completionHandler: completionHandler)
            } else {
                completionHandler(nil, NSError(domain: "com.laresivan.onthemap", code: 0, userInfo: nil))
                return
            }
        }
        
        task.resume()
    }
    
    // MARK: Convenience Methods
    
    /**
     Performs Udacity login
     - Parameter username: the account's email address
     - Parameter password: the account's password
     - Parameter completionHandler: called when login request is complete
     - Parameter success: true if login was successful
     - Parameter error: returns an error if login was not successful
     */
    func loginWith(username: String, password: String, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        let jsonBody: [String:Any] = [
            JsonKeys.loginCredentials: [
                JsonKeys.username : username,
                JsonKeys.password : password
            ]
        ]
        
        performPost(method: Methods.session, withJsonBody: jsonBody as [String:AnyObject]) { result, error in
            
            // check if performPost returned an error
            guard error == nil else {
                completionHandler(false, error)
                return
            }
            // check if the server returned an error
            if let errorString = result?["error"] as? String, let errorCode = result?["status"] as? Int{
                completionHandler(false, NSError(domain: "com.laresivan.onthemap", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            
            // used when there is an error accessing the results
            let unexpectedError = NSError(domain: "Unexpected", code: 0, userInfo: nil)
            
            // get userKey from results
            guard let userData = result?[JsonKeys.account] as? NSDictionary else {
                completionHandler(false, unexpectedError)
                return
            }
            guard let userKey = userData[JsonKeys.userKey] as? String else {
                completionHandler(false, unexpectedError)
                return
            }
            self.userKey = userKey
            
            // get sessionId from results
            guard let sessionResults = result?[JsonKeys.session] as? NSDictionary else {
                completionHandler(false, unexpectedError)
                return
            }
            guard let sessionId = sessionResults[JsonKeys.sessionID] as? String else {
                completionHandler(false, unexpectedError)
                return
            }
            self.sessionId = sessionId
            completionHandler(true, nil)
        }
    }
    
    
    // MARK: Helper
    
    /**
     Parses json data
     - Parameter data: json data to parse
     - Parameter completionHandler: called when parsing is complete
     - Parameter result: parsed json data
     - Parameter error: parsing error
    */
    class func parse(jsonData data: Data, completionHandler: (_ result: AnyObject?, _ error: Error?) -> Void) {
        // parse data and return results
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data.subdata(in: Range(uncheckedBounds: (lower: data.startIndex.advanced(by: 5), upper: data.endIndex))), options: .allowFragments) as AnyObject?
            
            completionHandler(parsedResult, nil)
        }
        catch let error as NSError {
            completionHandler(nil, error)
        }
    }

    
}

