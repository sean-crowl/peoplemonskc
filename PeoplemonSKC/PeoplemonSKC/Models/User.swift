//
//  User.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/6/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import Alamofire
import Freddy

class User: NetworkModel {
    var id: String?
    var email: String?
    var hasRegistered: Bool?
    var loginProvider: String?
    var fullName: String?
    var avatarBase64: String?
    var lastCheckInLatitude: Double?
    var lastCheckInLongitude: Double?
    var lastCheckInDateTime: String?
    var apiKey: String?
    var password: String?
    var token: String?
    var expiration: String?
    
    enum RequestType {
        case login
        case register
        case logout
        case userInfo
    }
    
    var requestType = RequestType.login
    
    required init() {}
    
    required init(json: JSON) throws {
        id = try? json.getString(at: Constants.User.id)
        email = try? json.getString(at: Constants.User.email)
        hasRegistered = try? json.getBool(at: Constants.User.hasRegistered)
        loginProvider = try? json.getString(at: Constants.User.loginProvider)
        fullName = try? json.getString(at: Constants.User.fullName)
        avatarBase64 = try? json.getString(at: Constants.User.avatarBase64)
        lastCheckInLatitude = try? json.getDouble(at: Constants.User.lastCheckInLatitude)
        lastCheckInLongitude = try? json.getDouble(at: Constants.User.lastCheckInLongitude)
        lastCheckInDateTime = try? json.getString(at: Constants.User.lastCheckInDateTime)
        
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        requestType = .login
    }
    
    init(email: String, fullName: String, password: String) {
        self.email = email
        self.fullName = fullName
        self.password = password
        requestType = .register
    }

    
    func method() -> Alamofire.HTTPMethod {
        return .get
    }
    
    func path() -> String {
        switch requestType {
        case .login:
            return "/token"
        case .register:
            return "/api/Account/Register"
        case .logout:
            return "/api/Account/Logout"
        case .userInfo:
            return "/api/Account/UserInfo"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .login:
            params[Constants.User.email] = email as AnyObject?
            params[Constants.User.password] = password as AnyObject?
        case .register:
            params[Constants.User.email] = email as AnyObject?
            params[Constants.User.fullName] = fullName as AnyObject?
            params[Constants.User.password] = password as AnyObject?
            params[Constants.User.apiKey] = apiKey as AnyObject?
        default:
            break
        }
        return params
    }
}

