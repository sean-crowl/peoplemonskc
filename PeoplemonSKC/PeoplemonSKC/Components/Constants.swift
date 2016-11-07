//
//  Constants.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/6/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

//
//  Constants.swift
//  EFAB
//
//  Created by Brett Keck on 5/17/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import UIKit

struct Constants {
    static let apiKey = "iOS301november2016"
    static let keychainIdentifier = "PeoplemonKeychain"
    static let authToken = "authToken"
    static let authTokenExpireDate = "authTokenExpireDate"
    
    struct JSON {
        static let unknownError = "An Unknown Error Has Occurred"
        static let processingError = "There was an error processing the response"
    }
    
    struct User {
        static let id = "Id"
        static let email = "Email"
        static let hasRegistered = "HasRegistered"
        static let loginProvider = "LoginProvider"
        static let fullName = "FullName"
        static let avatarBase64 = "AvatarBase64"
        static let lastCheckInLatitude = "LastCheckInLatitude"
        static let lastCheckInLongitude = "LastCheckInLongitude"
        static let lastCheckInDateTime = "LastCheckInDateTime"
        static let apiKey = "ApiKey"
        static let password = "Password"
        static let token = "access_token"
        static let expiration = "expiration"
        static let grantType = "grant_type"
    }
    
    struct Person {
        static let userID = "UserId"
        static let userName = "UserName"
        static let avatarBase64 = "AvatarBase64"
        static let longitude = "Longitude"
        static let latitude = "Latitude"
        static let created = "Created"
        static let caughtUserId = "CaughtUserId"
        static let radiusInMeters = "RadiusInMeters"
        
    }
    
}

