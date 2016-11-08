//
//  Person.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/6/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import Alamofire
import Freddy
import MapKit

class Person: NetworkModel {
    var userID: String?
    var userName: String?
    var avatarBase64: String?
    var longitude: Double?
    var latitude: Double?
    var created: String?
    var caughtUserId: String?
    var radiusInMeters: Double?
    
    enum RequestType {
        case nearby
        case checkIn
        case catchPerson
        case caught
    }
    
    var requestType = RequestType.nearby
    
    required init() {}
    
    required init(json: JSON) throws {
        self.userID = try? json.getString(at: Constants.Person.userId)
        self.userName = try? json.getString(at: Constants.Person.userName)
        self.avatarBase64 = try? json.getString(at: Constants.Person.avatarBase64)
        self.longitude = try? json.getDouble(at: Constants.Person.longitude)
        self.latitude = try? json.getDouble(at: Constants.Person.latitude)
        self.created = try? json.getString(at: Constants.Person.created)
    }
    
    init(radiusInMeters: Double) {
        self.radiusInMeters = radiusInMeters
        self.requestType = .nearby
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
        self.requestType = .checkIn
    }
    
    init(userID: String, radiusInMeters: Double) {
        self.userID = userID
        self.radiusInMeters = radiusInMeters
    }
    
    
    func method() -> Alamofire.HTTPMethod {
        switch requestType {
        case .nearby:
            return .get
        case .caught:
            return .get
        default:
            return .post
        }
    }
    
    func path() -> String {
        switch requestType {
        case .nearby:
            return "/v1/User/Nearby"
        case .checkIn:
            return "/v1/User/CheckIn"
        case .catchPerson:
            return "/v1/User/Catch"
        case .caught:
            return "/v1/User/Caught"
    }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .nearby:
            params[Constants.Person.radiusInMeters] = radiusInMeters as AnyObject?
        case .checkIn:
            params[Constants.Person.longitude] = longitude as AnyObject?
            params[Constants.Person.latitude] = latitude as AnyObject?
        case .catchPerson:
            params[Constants.Person.caughtUserId] = userID as AnyObject?
            params[Constants.Person.radiusInMeters] = radiusInMeters as AnyObject?
        case .caught:
            break
        }
        return params
    }
}

