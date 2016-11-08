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
    var fullName: String?
    var avatar: String?
    var password: String?
    var apiKey: String?
    var hasRegistered: Bool?
    var loginProvider: String?
    var latitude: Double?
    var longitude: Double?
    var token: String?
    var expirationDate: String?
    
    var requestType: RequestType = .login
    
    enum RequestType {
        case login
        case register
        case logout
        case userInfo
        case updateProfile
    }
    
    required init() {
        requestType = .userInfo
    }
    
    required init(json: JSON) throws {
        token = try? json.getString(at: Constants.User.token)
        expirationDate = try? json.getString(at: Constants.User.expirationDate)
        id = try? json.getString(at: Constants.User.id)
        email = try? json.getString(at: Constants.User.email)
        hasRegistered = try? json.getBool(at: Constants.User.hasRegistered)
        loginProvider = try? json.getString(at: Constants.User.loginProvider)
        fullName = try? json.getString(at: Constants.User.fullName)
        avatar = try? json.getString(at: Constants.User.avatarBase64)
        latitude = try? json.getDouble(at: Constants.User.latitude)
        longitude = try? json.getDouble(at: Constants.User.longitude)
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        requestType = .login
    }
    
    init(email: String, password: String, fullName: String) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.apiKey = Constants.apiKey
        requestType = .register
    }
    
    init(fullName: String, avatar: String) {
        self.fullName = fullName
        self.avatar = avatar
        requestType = .updateProfile
    }
    
    func method() -> Alamofire.HTTPMethod {
        switch requestType {
        case .userInfo:
            return .get
        default:
            return .post
        }
    }
    
    func path() -> String {
        switch requestType {
        case .login:
            return "/token"
        case .register:
            return "/api/Account/Register"
        case .logout:
            return "/api/Account/Logout"
        case .userInfo, .updateProfile:
            return "/api/Account/UserInfo"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .register:
            params[Constants.User.email] = email as AnyObject?
            params[Constants.User.fullName] = fullName as AnyObject?
            params[Constants.User.apiKey] = self.apiKey as AnyObject?
            params[Constants.User.password] = password as AnyObject?
        case .login:
            params[Constants.User.username] = email as AnyObject?
            params[Constants.User.password] = password as AnyObject?
            params[Constants.User.grantType] = Constants.User.password as AnyObject?
        case .updateProfile:
            params[Constants.User.fullName] = fullName as AnyObject?
            params[Constants.User.avatarBase64] = avatar as AnyObject?
        default:
            break
        }
        
        return params
    }
}
