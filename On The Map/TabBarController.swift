//
//  TabBarController.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 19/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var studentLocationArray: [StudentLocation] = []
    var user: StudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchStudentDetails()
    }
    
    func fetchStudentDetails() {
        let _ = UdacityClient.sharedInstance().getStudentLocations(100, nil, "-\(UdacityClient.JSONResponseKeys.UpdatedAt)", { (locations, error) in
            if let studentLocations = locations {
                self.studentLocationArray = studentLocations
                
                for location in studentLocations {
                    if let key = location.uniqueKey, let userKey = UdacityClient.sharedInstance().accountKey, key == userKey {
                        self.user = location
                        break
                    }
                }
                
                DispatchQueue.main.async {
                    if let vc = self.childViewControllers[0] as? MapViewController {
                        vc.addAnnotationForStudents(inArray: studentLocations)
                    }
                    if let vc = self.childViewControllers[1] as? StudentTableController {
                        vc.studentLocationUpdated()
                    }
                }
            }
        })
    }
    
    @IBAction func logoutUser(_ sender: Any) {
        
        showAnimatingIndicator()
        
        UdacityClient.sharedInstance().deleteSession { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.navigationController?.dismiss(animated: false, completion: nil)
                    })
                }
            }
        }
        
    }
    
    @IBAction func dropPinOnMap(_ sender: Any) {
        
        if let _ = user {
            
            let alert = UIAlertController(title: "Hey There!", message: "You have already posted a student location. Would you like to overwrite your current location?", preferredStyle: .alert)
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let overwriteAlertAction = UIAlertAction(title: "Overwrite", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: "userInformationVc", sender: self)
            })
            alert.addAction(overwriteAlertAction)
            alert.addAction(cancelAlertAction)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            self.performSegue(withIdentifier: "userInformationVc", sender: self)
        }
    }
    
    @IBAction func reloadLocations(_ sender: Any) {
        
        showAnimatingIndicator()
        
        refreshMap()
        
        fetchStudentDetails()
        
    }
    
    func showAnimatingIndicator() {
        if let vc = self.childViewControllers[0] as? MapViewController, vc.activityIndicator != nil {
            vc.activityIndicator.isHidden = false
            vc.activityIndicator.startAnimating()
        }
        if let vc = self.childViewControllers[1] as? StudentTableController, vc.activityIndicator != nil {
            vc.activityIndicator.isHidden = false
            vc.activityIndicator.startAnimating()
        }
    }
    
    func refreshMap() {
        if let vc = self.childViewControllers[0] as? MapViewController, vc.mapView != nil {
            vc.mapView.removeAnnotations(vc.mapView.annotations)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInformationVc" {
            let vc = segue.destination as! UserLocationViewController
            vc.userDelegate = self
            vc.userDetails = self.user
        }
    }
    
}

extension TabBarController: UserLocationDelegate {
    
    func userLocationPostedOrUpdated() {
        reloadLocations(self)
    }
    
}
