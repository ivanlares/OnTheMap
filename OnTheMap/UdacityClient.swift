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
    typealias LoginCompletion =
        ((userKey: String,firstName: String, lastName: String)?, _ error: Error?) -> ()
    
    // MARK: Request Methods 
    
    /**
        Performs an http post request with the following parameters
     
        - Parameter path: Aditional path components appended to the base url.
            - Aditional values are appended with foward-slash.
            - Example: resources/users
        - Parameter body: `Dictionary` representation of the json body used in the url request
        - Parameter completionHandler: closure to execute when request is complete
        - Parameter result: the resulting object if request is successful
        - Parameter error: the resulting error if request was unsuccessful
    */
    func performPost(withPath path: String, jsonBody body: [String:Any], completionHandler: @escaping(_ result: AnyObject?, _ error: Error?) -> Void){
        
        // configure request
        let urlString = Url.base + path
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
    
    /**
     Performs Get request
     - Parameter path: Aditional path components appended to the base url
        - Aditional values are appended with foward-slash.
        - Example: resources/users
     */
    func performGet(withPath path: String, completionHandler: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        
        // configure request
        let urlString = Url.base + path
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

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
    func loginWith(username: String, password: String, completionHandler: @escaping LoginCompletion) {
        
        let jsonBody: [String:Any] = [
            JsonKeys.loginCredentials: [
                JsonKeys.username : username,
                JsonKeys.password : password
            ]
        ]
        
        performPost(withPath: PathKeys.session, jsonBody: jsonBody as [String:AnyObject]) { results, error in
            
            // check if performPost returned an error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            // check if the server returned an error
            if let errorString = results?[JsonKeys.error] as? String, let
                errorCode = results?[JsonKeys.status] as? Int{
                completionHandler(nil, NSError(domain: "com.laresivan.onthemap", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            // extract data from results
            guard let userData = results?[JsonKeys.account] as? NSDictionary,
                let userKey = userData[JsonKeys.userKey] as? String,
                let sessionResults = results?[JsonKeys.session] as? NSDictionary,
                let sessionId = sessionResults[JsonKeys.sessionID] as? String
                else {
                completionHandler(nil, LoginError.UnableToRetrieveUserData)
                return
            }
            self.userKey = userKey
            self.sessionId = sessionId
            // Get user Name
            self.getStudentName(withUserId: userKey, completion: completionHandler)
        }
    }
    
    func getStudentName(withUserId id: String, completion: @escaping LoginCompletion){
        guard let userKey = userKey else { return }
        let path = PathKeys.users+"/"+userKey
        
        performGet(withPath: path){ (results: Any?, error: Error?) in
            // Handle errors
            guard error == nil else{
                completion(nil, error)
                return
            }
            guard
                let results = results as? [String:Any],
                let studentData = results[JsonKeys.user] as? [String: Any],
                let firstName = studentData[JsonKeys.firstName] as? String,
                let lastName = studentData[JsonKeys.lastName] as? String else {
                    completion(nil, LoginError.UnableToRetrieveUserData)
                    return
            }
            completion((id, firstName, lastName), nil)
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
    

    
    // MARK: OTHER 
    
    func logout(){
        // Example code provided by Udacity
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count - 5))
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
    
}

