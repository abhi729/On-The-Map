//
//  StudentLocation.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 15/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaUrlString: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String?
    let updatedAt: String?
 
    // construct a location from a dictionary
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary[UdacityClient.JSONResponseKeys.ObjectId] as? String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[UdacityClient.JSONResponseKeys.MapString] as? String
        mediaUrlString = dictionary[UdacityClient.JSONResponseKeys.MediaUrlString] as? String
        latitude = dictionary[UdacityClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[UdacityClient.JSONResponseKeys.Longitude] as? Double
        createdAt = dictionary[UdacityClient.JSONResponseKeys.CreatedAt] as? String
        updatedAt = dictionary[UdacityClient.JSONResponseKeys.UpdatedAt] as? String
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()

        // iterate through array of dictionaries, each location is a dictionary
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
}
