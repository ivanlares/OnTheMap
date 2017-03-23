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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        activityIndicator.startAnimating()
        
        //TODO: Show custom error message for each guard
        guard let email = emailTextField.text else {
            activityIndicator.stopAnimating()
            return
        }
        guard let password = passwordTextField.text else {
            activityIndicator.stopAnimating()
            return
        }
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activityIndicator.stopAnimating()
            return
        }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activityIndicator.stopAnimating()
            return
        }

        login(){
            performOnMain{
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Helper
    
    func setDelegates(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func login(completion:@escaping ()->()){
        UdacityClient.sharedInstance.loginWith(username: emailTextField.text!, password: passwordTextField.text!){
            (userData: (userKey:String,firstName:String,lastName:String)?, error) in
            completion()
            guard error == nil else {
                print(error!)
                return
            }
            guard let userData = userData else {
                print(LoginError.unableToRetrieveUserData)
                return
            }
            performOnMain{
                SharedData.sharedInstance.currentUser = UdacityUser(userKey: userData.userKey, firstName: userData.firstName, lastName: userData.lastName)
                self.presentTabController()
            }
        }
    }
    
    func presentTabController(){
        emailTextField.text = nil
        passwordTextField.text = nil

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
