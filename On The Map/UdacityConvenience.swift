//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 15/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation

extension UdacityClient {
        
    func getStudentLocations(_ limitBy: Int?,_ skipBy: Int? ,_ orderBy: String?, _ completionHandlerForStudentLocation: @escaping (_ result: [StudentLocation]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        var parameters: [String: AnyObject] = [:]
        if let limit = limitBy {
            parameters[ParameterKeys.Limit] = limit as AnyObject
        }
        if let skip = skipBy {
            parameters[ParameterKeys.Skip] = skip as AnyObject
        }
        if let order = orderBy {
            parameters[ParameterKeys.Order] = order as AnyObject
        }
        let task = taskForGETMethod(Methods.StudentLocation, host: Constants.ParseApiHost, parameters: parameters) { (results, error) in
            if let error = error {
                completionHandlerForStudentLocation(nil, error)
            } else {
                if let result = results as? [String: AnyObject], let studentLocations = result[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                    let locations = StudentLocation.locationsFromResults(studentLocations)
                    completionHandlerForStudentLocation(locations, nil)
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Results) in \(results!)")
                    completionHandlerForStudentLocation(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
        return task
        
    }
    
    func getSingleStudentLocation(havingUniqueId uniqueId: String?, _ completionHandlerForSingleStudentLocation: @escaping (_ result: StudentLocation?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        var parameters: [String: AnyObject] = [:]
        if let id = uniqueId {
            parameters[ParameterKeys.Where] = "{\(ParameterKeys.UniqueId):\(id)}".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) as AnyObject
        }
        let task = taskForGETMethod(Methods.StudentLocation, host: Constants.ParseApiHost, parameters: parameters) { (results, error) in
            if let error = error {
                completionHandlerForSingleStudentLocation(nil, error)
            } else {
                if let result = results as? [String: AnyObject], let studentLocations = result[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                    let locations = StudentLocation.locationsFromResults(studentLocations)
                    if locations.count != 0 {
                        completionHandlerForSingleStudentLocation(locations[0], nil)
                    } else {
                        completionHandlerForSingleStudentLocation(nil, nil)
                    }
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Results) in \(results!)")
                    completionHandlerForSingleStudentLocation(nil, NSError(domain: "getSingleStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getSingleStudentLocation"]))
                }
            }
        }
        return task
    }
    
    func updateStudentLocation(forStudent student: StudentLocation, _ completionHandlerForUpdateLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        if let objectId = student.objectId, let key = self.accountKey, let first = student.firstName, let last = student.lastName, let mapString = student.mapString, let mediaUrl = student.mediaUrlString, let lat = student.latitude, let long = student.longitude {
        
            let urlString = "\(Constants.ApiScheme)://\(Constants.ParseApiHost)\(Methods.StudentLocation)/\(objectId)"
            if let url = URL(string: urlString) {
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "PUT"
                request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: HeaderKeys.ApiKey)
                request.addValue(Constants.ParseApplicationId, forHTTPHeaderField: HeaderKeys.AppId)
                request.addValue(Constants.ContentTypeValue, forHTTPHeaderField: ParameterKeys.ContentType)
                request.httpBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(first)\", \"lastName\": \"\(last)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\", \"latitude\": \(lat), \"longitude\": \(long)}".data(using: String.Encoding.utf8)
                let task = session.dataTask(with: request as URLRequest) { data, response, error in
                    if let error = error {
                        completionHandlerForUpdateLocation(false, error as NSError)
                        return
                    }
                    var parsedResult: AnyObject! = nil
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                        
                        if let result = parsedResult as? [String: AnyObject] {
                            let updatedAt = result[JSONResponseKeys.UpdatedAt] as? String
                            if updatedAt != nil, updatedAt != "" {
                                completionHandlerForUpdateLocation(true, nil)
                            } else {
                                completionHandlerForUpdateLocation(false, NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data!)'"]))
                            }
                        }
                    } catch {
                        completionHandlerForUpdateLocation(false, NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data!)'"]))
                    }
                    
                }
                task.resume()
            }
        }
        
        
    }
    
    func postStudentLocation(forStudent student: StudentLocation, _ completionHandlerPostLocation: @escaping (_ objectId: String?, _ error: NSError?) -> Void) {
        
        if let key = self.accountKey, let first = student.firstName, let last = student.lastName, let mapString = student.mapString, let mediaUrl = student.mediaUrlString, let lat = student.latitude, let long = student.longitude {
         
            let jsonBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(first)\", \"lastName\": \"\(last)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\", \"latitude\": \(lat), \"longitude\": \(long)}"
            
            let parameters = [
                HeaderKeys.ApiKey: Constants.ParseAPIKey,
                HeaderKeys.AppId: Constants.ParseApplicationId,
                ParameterKeys.ContentType: Constants.ContentTypeValue
            ]
            
            let _ = taskForPOSTMethod(Methods.StudentLocation, host: Constants.ParseApiHost, headerParameters: parameters, parameters: [:], jsonBody: jsonBody, completionHandlerForPOST: { (results, error) in
                
                if let result = results as? [String: AnyObject] {
                    print(result)
                    
                    if let objectId = result[JSONResponseKeys.ObjectId] as? String {
                        completionHandlerPostLocation(objectId, nil)
                    } else {
                        completionHandlerPostLocation(nil, NSError(domain: "postStudentLocation request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error in parsing"]))
                    }
                    
                } else {
                    completionHandlerPostLocation(nil, NSError(domain: "postStudentLocation request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error in parsing"]))
                }
                
            })

            
        } else {
            completionHandlerPostLocation(nil, NSError(domain: "postStudentLocation request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Insufficient Params"]))
        }

    }
    
    func createSession(username: String, password: String, _ completionHandlerForCreateSession: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let jsonBody = "{\"\(JSONBodyKeys.Udacity)\": {\"\(JSONBodyKeys.Username)\": \"\(username)\", \"\(JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        let parameters = [
            ParameterKeys.Accept: Constants.AcceptValue,
            ParameterKeys.ContentType: Constants.ContentTypeValue
        ]
        
        let _ = taskForPOSTMethod(Methods.Session, host: Constants.UdacityApiHost, headerParameters: parameters, parameters: [:], jsonBody: jsonBody) { (results, error) in
            if let result = results as? [String: AnyObject] {
                print(result)
                
                if let account = result[JSONResponseKeys.Account] as? [String: AnyObject], let registered = account[JSONResponseKeys.Registered] as? Bool, let key = account[JSONResponseKeys.Key] as? String {
                    self.accountKey = key
                    self.accountRegistered = registered
                }
                
                if let session = result[JSONResponseKeys.Session] as? [String: AnyObject], let id = session[JSONResponseKeys.Id] as? String, let expiration = session[JSONResponseKeys.Expiration] as? String {
                    self.sessionId = id
                    self.sessionExpiration = expiration
                }
                
                completionHandlerForCreateSession(true, nil)
            } else {
                completionHandlerForCreateSession(false, error)
            }
        }
    }
    
    func deleteSession(_ completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        if let url = URL(string: Constants.ApiScheme + "://" + Constants.UdacityApiHost + Methods.Session) {
            print(url)
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    completionHandlerForDeleteSession(false, error)
                }
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
                
                self.accountKey = nil
                self.accountRegistered = nil
                self.sessionId = nil
                self.sessionExpiration = nil
                
                completionHandlerForDeleteSession(true, nil)
            }
            task.resume()
        } else {
            completionHandlerForDeleteSession(false, NSError(domain: "deleteSession request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Url"]))
        }
        
    }
    
    func getPublicUserData(_ completionHandlerForUserData: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        if let key = self.accountKey, let url = URL(string: "\(Constants.ApiScheme)://\(Constants.UdacityApiHost)\(Methods.Users)/\(key)") {
            let request = NSMutableURLRequest(url: url)
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    return
                }
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as AnyObject
                    
                    if let result = parsedResult as? [String: AnyObject], let user = result[JSONResponseKeys.User] as? [String: AnyObject] {
                        self.firstName = user[JSONResponseKeys.UserFirstName] as? String
                        self.lastName = user[JSONResponseKeys.UserLastName] as? String
                    }
                    completionHandlerForUserData(true, nil)
                } catch {
                    completionHandlerForUserData(false, NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(newData!)'"]))
                }
            }
            task.resume()
        }
    }
    
}
