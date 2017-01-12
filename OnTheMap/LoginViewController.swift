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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override func viewDidLoad() {
        setDelegates()
    }
    
    // MARK: Target Action
    
    @IBAction func didPressLogin(_ sender: UIButton) {
        // check for nil 
        guard let email = emailTextField.text else {
            return
        }
        guard let password = passwordTextField.text else {
            return
        }
        // check for white space
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        login()
    }
    
    // MARK: Helper
    
    func setDelegates(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func login(){
        UdacityClient.sharedInstance.loginWith(username: emailTextField.text!, password: passwordTextField.text!){ success, error in
            if success{
                DispatchQueue.main.async {
                    self.transitonToStudentData()
                    return
                }
            }
        }
    }
    
    func transitonToStudentData(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentInfoTabBarController = storyboard.instantiateViewController(withIdentifier: "StudentInfoTabBar")
        present(studentInfoTabBarController, animated: true, completion: nil)
    }

}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
