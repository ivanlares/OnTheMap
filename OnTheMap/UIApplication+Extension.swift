//
//  UIApplication+Extension.swift
//  OnTheMap
//
//  Created by ivan lares on 4/5/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import UIKit

extension UIApplication{
    func open(urlString: String?){
        guard let urlString = urlString, let url = URL(string: urlString)  else {
            return
        }
        if self.canOpenURL(url){
            self.open(url)
        }
    }
}
