//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by ivan lares on 1/14/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation

func performOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
