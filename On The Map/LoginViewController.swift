//
//  LoginViewController.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 15/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookSigninButton: UIButton!
    
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        loginButton.isUserInteractionEnabled = false
        actionForLogin()
    }
    
    @IBAction func facebookSigninPressed(_ sender: AnyObject) {
        
    }
    
    func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func actionForLogin() {
        if let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" {
            loginActivityIndicator.isHidden = false
            loginActivityIndicator.startAnimating()
            UdacityClient.sharedInstance().createSession(username: email, password: password, { (success, error) in
                if success {
                    UdacityClient.sharedInstance().getPublicUserData({ (success, error) in
                        DispatchQueue.main.async {
                            self.loginActivityIndicator.stopAnimating()
                            self.loginActivityIndicator.isHidden = true
                            self.loginButton.isUserInteractionEnabled = true
                        }
                        if success {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "navigationController", sender: self)
                            }
                        } else if let error = error {
                            DispatchQueue.main.async {
                                self.alertUser(title: "Oops!", message: error.localizedDescription)
                            }
                        }
                    })
                    
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.loginActivityIndicator.stopAnimating()
                        self.loginActivityIndicator.isHidden = true
                        self.loginButton.isUserInteractionEnabled = true
                        self.alertUser(title: "Oops!", message: error.localizedDescription)
                    }
                }
            })
        } else {
            alertUser(title: "Oops!", message: "Email/Password cannot be empty!")
            loginButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: AnyObject) {
        if let signupUrl = URL(string: UdacityClient.Constants.UdacitySignUpLink), UIApplication.shared.canOpenURL(signupUrl) {
            UIApplication.shared.open(signupUrl, options: [:], completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addPaddingToTheLeft()
        passwordTextField.addPaddingToTheLeft()
        loginActivityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            actionForLogin()
        }
        return true
    }
    
}

extension UITextField {
    
    func addPaddingToTheLeft() {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}

