//
//  Array+Extension.swift
//  OnTheMap
//
//  Created by ivan lares on 3/24/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit

extension UIAlertController{
    class func alert(withTitle title: String, message: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "ok", style: .default)
        alertController.addAction(okAction)
        
        return alertController
    }
}
