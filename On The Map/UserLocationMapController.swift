//
//  UserLocationMapController.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 20/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import UIKit
import MapKit

protocol UserMapDelegate {
    
    func errorOccured(title: String, message: String)
    func infoSuccessfullySubmitted()
}

class UserLocationMapController: UIViewController {
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationString: String!
    
    var userRegion: MKCoordinateRegion?
    
    var userDelegate: UserMapDelegate!
    
    var userDetails: StudentLocation?
    
    @IBAction func submitStudentInformation(_ sender: AnyObject) {
        
        if let mediaText = linkTextField.text, mediaText != "" {
            if let details = userDetails, let id = details.objectId {
                
                if let region = userRegion, let key = UdacityClient.sharedInstance().accountKey, let firstName = UdacityClient.sharedInstance().firstName, let lastName = UdacityClient.sharedInstance().lastName {
                    
                    let dict: [String: AnyObject] = [
                        UdacityClient.JSONResponseKeys.ObjectId: id as AnyObject,
                        UdacityClient.JSONResponseKeys.FirstName: firstName as AnyObject,
                        UdacityClient.JSONResponseKeys.LastName: lastName as AnyObject,
                        UdacityClient.JSONResponseKeys.UniqueKey: key as AnyObject,
                        UdacityClient.JSONResponseKeys.MediaUrlString: mediaText as AnyObject,
                        UdacityClient.JSONResponseKeys.MapString: locationString as AnyObject,
                        UdacityClient.JSONResponseKeys.Latitude: region.center.latitude as AnyObject,
                        UdacityClient.JSONResponseKeys.Longitude: region.center.longitude as AnyObject
                    ]
                    
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                    
                    let student = StudentLocation(dictionary: dict)
                    
                    UdacityClient.sharedInstance().updateStudentLocation(forStudent: student, { (success, error) in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                        if let error = error {
                            DispatchQueue.main.async {
                                self.userDelegate.errorOccured(title: "Oops", message: error.localizedDescription)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.userDelegate.infoSuccessfullySubmitted()
                            }
                        }
                    })
                }
            } else {
                if let region = userRegion, let key = UdacityClient.sharedInstance().accountKey, let firstName = UdacityClient.sharedInstance().firstName, let lastName = UdacityClient.sharedInstance().lastName {
                    
                    let dict: [String: AnyObject] = [
                        UdacityClient.JSONResponseKeys.FirstName: firstName as AnyObject,
                        UdacityClient.JSONResponseKeys.LastName: lastName as AnyObject,
                        UdacityClient.JSONResponseKeys.UniqueKey: key as AnyObject,
                        UdacityClient.JSONResponseKeys.MediaUrlString: mediaText as AnyObject,
                        UdacityClient.JSONResponseKeys.MapString: locationString as AnyObject,
                        UdacityClient.JSONResponseKeys.Latitude: region.center.latitude as AnyObject,
                        UdacityClient.JSONResponseKeys.Longitude: region.center.longitude as AnyObject
                    ]
                    
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                    
                    let student = StudentLocation(dictionary: dict)
                    
                    UdacityClient.sharedInstance().postStudentLocation(forStudent: student, { (objectId, error) in
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                        if let error = error {
                            DispatchQueue.main.async {
                                self.userDelegate.errorOccured(title: "Oops", message: error.localizedDescription)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.userDelegate.infoSuccessfullySubmitted()
                            }
                        }
                    })
                }
            }
        } else {
            userDelegate.errorOccured(title: "Oops", message: "Media Url cannot be empty!")
        }

    }
    
    func evaluateRegionAndDisplay() {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationString) { (placemarks, error) in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.userDelegate.errorOccured(title: "Oops", message: "Location not found!")
                    self.activityIndicator.stopAnimating()
                    
                }
                return
            }
            
            if let placemark = placemarks?.first {
                
                let mkPlacemark = MKPlacemark(placemark: placemark)
                
                let spanDelta: CLLocationDegrees = 0.01
                let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
                let region = MKCoordinateRegion(center: mkPlacemark.coordinate, span: span)
                
                self.userRegion = region
                
                DispatchQueue.main.async {
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(mkPlacemark)
                    self.activityIndicator.stopAnimating()
                }
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        evaluateRegionAndDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension UserLocationMapController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
