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
        
        guard let email = emailTextField.text,
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activityIndicator.stopAnimating()
            let alert = UIAlertController.alert(withTitle: "Whoops", message: "Please enter a valid email address.")
            present(alert, animated: true)
            return
        }
        guard let password = passwordTextField.text,
            !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            activityIndicator.stopAnimating()
            let alert = UIAlertController.alert(withTitle: "Whoops", message: "Please enter a valid password.")
            present(alert, animated: true)
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
