//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by ivan lares on 1/6/17.
//  Copyright © 2017 ivan lares. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        setDelegates()
    }
    
    // MARK: Target Action
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func didPressLogin(_ sender: UIButton) {
    }
    
    // MARK: Helper
    
    func setDelegates(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
