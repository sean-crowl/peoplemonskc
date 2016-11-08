//
//  UserStore.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import Foundation

protocol UserStoreDelegate: class {
    func userLoggedIn()
}

class UserStore {
    static let shared = UserStore()
    
    var user: User? {
        didSet {
            if let _ = user {
                delegate?.userLoggedIn()
            }
        }
    }
    weak var delegate: UserStoreDelegate?
    
    func login(_ loginUser: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        WebServices.shared.authUser(loginUser) { (user, error) -> () in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expirationDate)
                self.getUserInfo(infoUser: loginUser, completion: completion)
            } else {
                completion(false, error)
            }
        }
    }
    
    func register(_ registerUser: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        WebServices.shared.registerUser(registerUser) { (user, error) -> () in
            if let _ = user {
                registerUser.requestType = User.RequestType.login
                self.login(registerUser, completion: { (success, error) in
                    completion(success, error)
                })
            } else {
                completion(false, error)
            }
        }
    }
    
    func getUserInfo(infoUser: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        infoUser.requestType = User.RequestType.userInfo
        WebServices.shared.getObject(infoUser) { (user, error) in
            if let user = user {
                self.user = user
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func logout(completion:@escaping () -> Void) {
        let logoutUser = User()
        logoutUser.requestType = User.RequestType.logout
        WebServices.shared.postObject(logoutUser) { (object, error) in
            WebServices.shared.clearUserAuthToken()
            completion()
        }
    }
}
