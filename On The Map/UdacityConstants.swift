//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 15/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

extension UdacityClient {
    
    //MARK: Constants
    struct Constants {
    
        // MARK: API Key
        static let ParseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ParseApiHost = "parse.udacity.com"
        
        static let UdacityApiHost = "www.udacity.com"
        
        static let UdacitySignUpLink = "https://www.udacity.com/account/auth#!/signup"
        
        static let AcceptValue = "application/json"
        static let ContentTypeValue = "application/json"
        
    }
    
    // MARK: Methods
    struct Methods {
        static let StudentLocation = "/parse/classes/StudentLocation"
        static let Session = "/api/session"
        static let Users = "/api/users"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Student Location
        static let Results = "results"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrlString = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        
        // MARK: Session
        static let Status = "status"
        static let Error = "error"
        static let Account = "account"
        static let Session = "session"
        static let Registered = "registered"
        static let Key = "key"
        static let Id = "id"
        static let Expiration = "expiration"
        
        // MARK: User Public Data
        static let User = "user"
        static let UserLastName = "last_name"
        static let UserFirstName = "first_name"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        // MARK: Student Location
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let UniqueId = "uniqueKey"
        
        
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    // MARK: Header Keys
    struct HeaderKeys {
        static let AppId = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
}
