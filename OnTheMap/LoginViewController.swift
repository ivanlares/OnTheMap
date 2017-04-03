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
    enum LoginError: LocalizedError{
        case invalidEmail
        case invalidPassword
        case clientError
        
        var errorDescription: String?{
            switch self {
            case .invalidEmail: return "Invalid email."
            case .invalidPassword: return "Invalid Password"
            case .clientError: return "Unexpected server error"
            }
        }
    }
    
    override func viewDidLoad() {
        setDelegates()
    }
    
    // MARK: Target Action
    
    @IBAction func didPressLogin(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                stopActivityIndicator()
                let alert = UIAlertController.alert(withTitle: "Whoops", message: LoginError.invalidEmail.localizedDescription)
                present(alert, animated: true)
                return
        }
        guard let password = passwordTextField.text,
            !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                stopActivityIndicator()
                let alert = UIAlertController.alert(withTitle: "Whoops", message: LoginError.invalidPassword.localizedDescription)
                present(alert, animated: true)
                return
        }
        
        login() { error in
            self.stopActivityIndicator()
            
            guard let error = error else{ return }
            performOnMain {
                let alert = UIAlertController.alert(withTitle: "Error", message: error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: Helper
    
    func setDelegates(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func login(completion:@escaping (Error?)->()){
        UdacityClient.sharedInstance.loginWith(username: emailTextField.text!, password: passwordTextField.text!){
            (userData: (userKey:String,firstName:String,lastName:String)?, error) in
            
            guard error == nil else {
                completion(error)
                return
            }
            guard let userData = userData else {
                completion(LoginError.clientError)
                return
            }
            performOnMain{
                SharedData.sharedInstance.currentUser = UdacityUser(userKey: userData.userKey, firstName: userData.firstName, lastName: userData.lastName)
                self.presentTabController()
                completion(nil)
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
    
    /// stops activity indicator on the main thread
    func stopActivityIndicator(){
        performOnMain{
            self.activityIndicator.stopAnimating()
        }
    }

}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
