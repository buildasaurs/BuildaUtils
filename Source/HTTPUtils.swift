//
//  HTTPUtils.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 13/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

open class HTTP {
    
    open var session: URLSession
    
    public init(session: URLSession?) {
        
        if let session = session {
            self.session = session
        } else {
            
            let configuration = URLSessionConfiguration.default
            
            //disable all caching
            configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            configuration.urlCache = nil
            
            let session = URLSession(configuration: configuration)
            self.session = session
        }
    }
    
    public typealias Completion = (_ response: URLResponse?, _ body: Any?, _ error: Error?) -> ()

    open func sendRequest(_ request: URLRequest, completion: @escaping Completion) -> URLSessionTask {
        
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            //try to cast into HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                
                guard error == nil else {
                    //error in the networking stack
                    completion(httpResponse, nil, error)
                    return
                }
                
                guard let data = data else {
                    //no body, but a valid response
                    completion(httpResponse, nil, nil)
                    return
                }
                
                let code = httpResponse.statusCode
                
                //error is nil and data isn't, let's check the content type
                if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                    
                    switch contentType {
                        
                    case let s where s.range(of: "application/json") != nil:
                        
                        let (json, error) = JSON.parse(data)
                        // let headers = httpResponse.allHeaderFields
                        completion(httpResponse, json, error)
                        
                    default:
                        //parse as UTF8 string
                        let string = String(data: data, encoding: String.Encoding.utf8)
                        
                        //check for common problems
                        let userInfo: NSDictionary? = {
                            
                            switch code {
                            case 401:
                                return ["Response": string]
                            default:
                                return nil;
                            }
                            }()
                        
                        let commonError: NSError? = {
                            if let userInfo = userInfo {
                                return MyError.withInfo(nil, internalError: nil, userInfo: userInfo)
                            }
                            return nil
                            }()
                        
                        completion(httpResponse, string, commonError)
                    }
                } else {
                    
                    //no content type, probably a 204 or something - let's just send the code as the content object
                    completion(httpResponse, code, error)
                }
            } else {
                let e = error ?? MyError.withInfo("Response is nil")
                completion(nil, nil, e)
            }
        })
        
        task.resume()
        return task
    }
}

extension HTTP {
    
    public enum Method : String {
        case GET = "GET"
        case POST = "POST"
        case PATCH = "PATCH"
        case DELETE = "DELETE"
        case PUT = "PUT"
    }

    /**
    Class method for generating query String based on input Dictionary.
    
    - parameter query: Optional Dictionary of type [String: String]
    
    - returns: Query or empty String
    */
    public class func stringForQuery(_ query: [String : String]?) -> String {
        guard let query = query , query.count > 0 else {
            return ""
        }
        
        let pairs = query.keys.sorted().map { "\($0)=\(query[$0]!)" }
        let full = "?" + pairs.joined(separator: "&")
        
        return full
    }
    
}
