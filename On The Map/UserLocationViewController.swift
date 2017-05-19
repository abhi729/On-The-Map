//
//  UserLocationViewController.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 20/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit

protocol UserLocationDelegate {
    func userLocationPostedOrUpdated()
}

class UserLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var userLocationMapView: UIView!
    
    var userDetails: StudentLocation?
    
    var locationMapController: UserLocationMapController?
    
    var userDelegate: UserLocationDelegate!
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        if let _ = locationMapController {
            self.dismissMapView()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func findOnMap(_ sender: AnyObject) {
        locationTextField.resignFirstResponder()
        actionForFindOnMap()
    }
    
    func actionForFindOnMap() {
        if let locationText = locationTextField.text, locationText != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            locationMapController = storyboard.instantiateViewController(withIdentifier: "UserLocationMapController") as? UserLocationMapController
            self.locationMapController!.locationString = locationText
            self.locationMapController!.userDelegate = self
            self.locationMapController!.userDetails = userDetails
            self.add(asChildViewController: self.locationMapController!, inView: userLocationMapView)
            self.userLocationMapView.isHidden = false
        } else {
            displayAlertToUser(title: "Oops!", message: "Location cannot be empty!")
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if locationTextField.isEditing {
            self.view.transform = CGAffineTransform(translationX: 0, y: -getKeyboardHeight(notification))
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if locationTextField.isEditing {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func add(asChildViewController viewController: UIViewController, inView parentView: UIView) {
        addChildViewController(viewController)
        parentView.addSubview(viewController.view)
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func displayAlertToUser(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UserLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        actionForFindOnMap()
        return true
    }
    
}

extension UserLocationViewController: UserMapDelegate {
    
    func errorOccured(title: String, message: String) {
        dismissMapView()
        displayAlertToUser(title: title, message: message)
    }
    
    func infoSuccessfullySubmitted() {
        dismissMapView()
        userDelegate.userLocationPostedOrUpdated()
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissMapView() {
        if let controller = locationMapController {
            self.userLocationMapView.isHidden = true
            self.remove(asChildViewController: controller)
            locationMapController = nil
        }
    }
}
