//
//  NetworkModel.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/6/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

// Describes what you need to make a network request and read it
protocol NetworkModel: JSONDecodable {
    // create the object by reading JSON
    init(json: JSON) throws
    // create an empty object
    init()
    
    // what is the HTTP Method (Get/Post/Put/etc)
    func method() -> Alamofire.HTTPMethod
    // REST URL to the resource i.e. http://server.com/posts/1
    func path() -> String
    // Convert the object to a dictionary for later conversion to JSON
    func toDictionary() -> [String: AnyObject]?
}
