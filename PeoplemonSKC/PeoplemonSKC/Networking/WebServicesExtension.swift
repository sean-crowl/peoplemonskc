//
//  WebServicesExtension.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/6/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

extension WebServices {
    // Step 5: Create generic function to get single model back
    func getObject<T: NetworkModel>(_ model: T, completion: @escaping (_ object: T?, _ error: String?) -> Void) {
        request(AuthRouter.restRequest(model)).responseJSON { (response) in
            WebServices.parseResponseObject(response: response, completion: completion)
        }
    }
    
    // Step 6: Create generic functions for creating an object as well as getting back an array of objects
    func postObject<T: NetworkModel>(_ model: T, completion: @escaping (_ object: T?, _ error: String?) -> Void) {
        request(AuthRouter.restRequest(model)).responseJSON { (response) in
            WebServices.parseResponseObject(response: response, completion: completion)
        }
    }
    
    func getObjects<T: NetworkModel>(_ model: T, completion: @escaping (_ objects: [T]?, _ error: String?) -> Void) {
        request(AuthRouter.restRequest(model)).responseJSON { (response) in
            WebServices.parseResponseObjects(response: response, completion: completion)
        }
    }
    
    
    // MARK: - Response parsing functions
    // Step 5: Create generic function to process singular object
    class func parseResponseObject<T: NetworkModel>(response: DataResponse<Any>, completion: (_ object: T?, _ error: String?) -> Void) {
        var object: T?
        
        guard case .success(_) = response.result, let data = response.data else {
            if let statusCode = response.response?.statusCode, statusCode >= 200, statusCode < 300 {
                completion(T(), nil)
            } else {
                completion(nil, parseError(response: response))
            }
            return
        }
        
        do {
            let json = try JSON(data: data)
            object = try T(json: json)
            
            completion(object, nil)
        } catch {
            completion(nil, Constants.JSON.processingError)
        }
    }
    
    class func parseError(response: DataResponse<Any>) -> String? {
        guard case let .failure(error) = response.result else {
            return Constants.JSON.unknownError
        }
        
        var errorString: String?
        
        if let error = error as? AFError {
            switch error {
            case .invalidURL(let url):
                errorString = "Invalid URL: \(url) - \(error.localizedDescription)"
            case .parameterEncodingFailed(let reason):
                errorString = "Parameter encoding failed: \(error.localizedDescription) Failure Reason: \(reason)"
            case .multipartEncodingFailed(let reason):
                errorString = "Multipart encoding failed: \(error.localizedDescription) Failure Reason: \(reason)"
            case .responseValidationFailed(let reason):
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    errorString = "Downloaded file could not be read"
                case .missingContentType(let acceptableContentTypes):
                    errorString = "Content Type Missing: \(acceptableContentTypes)"
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    errorString = "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                case .unacceptableStatusCode(let code):
                    errorString = "Response status code was unacceptable: \(code)"
                }
            case .responseSerializationFailed(let reason):
                errorString = "Response serialization failed: \(error.localizedDescription) Failure Reason: \(reason)"
            }
        } else if let error = error as? URLError {
            errorString = "URLError occurred: \(error)"
        } else {
            errorString = "Unknown error: \(error)"
        }
        
        return errorString
    }
    
    
    // Step 6: Create generic function to process array of objects
    class func parseResponseObjects<T: NetworkModel>(response: DataResponse<Any>, completion: (_ objects: [T]?, _ error: String?) -> Void) {
        var errorString: String?
        var objects: [T]?
        
        guard case .success(_) = response.result, let data = response.data else {
            completion(nil, parseError(response: response))
            return
        }
        
        do {
            let json = try JSON(data: data)
            let people = try json.getArray().map(T.init)
            objects = people
        } catch {
            errorString = Constants.JSON.processingError
        }
        
        completion(objects, errorString)
    }
    
    func authUser<T: NetworkModel>(_ user: T, completion:@escaping (_ user: T?, _ error: String?) -> ()) {
        request(WebServices.shared.baseURL + user.path(), method: user.method(), parameters: user.toDictionary(), encoding: URLEncoding.default)
            .responseJSON { (response) in
                WebServices.parseResponseObject(response: response, completion: completion)
        }
    }
    
    func registerUser<T: NetworkModel>(_ user: T, completion:@escaping (_ user: T?, _ error: String?) -> ()) {
        request(WebServices.shared.baseURL + user.path(), method: user.method(), parameters: user.toDictionary(), encoding: URLEncoding.default)
            .responseJSON { (response) in
                WebServices.parseResponseObject(response: response, completion: completion)
        }
    }
}
