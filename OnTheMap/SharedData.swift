//
//  SharedData.swift
//  OnTheMap
//
//  Created by ivan lares on 1/13/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

class SharedData{
    
    static let sharedInstance = SharedData()
    var studentLocations: [StudentLocation] = []
    var currentUser: UdacityUser?
    
    private init() {}
}

