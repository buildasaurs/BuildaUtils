//
//  SimpleURLCache.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 1/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Foundation
import SwiftSafe

open class ResponseInfo: AnyObject {
    open let response: HTTPURLResponse
    open let body: AnyObject?
    
    public init(response: HTTPURLResponse, body: AnyObject?) {
        self.response = response
        self.body = body
    }
}

public struct CachedInfo {
    public let responseInfo: ResponseInfo?
    public let update: (ResponseInfo) -> ()
    
    public var etag: String? {
        guard let responseInfo = self.responseInfo else { return nil }
        return responseInfo.response.allHeaderFields["ETag"] as? String
    }
}

public protocol URLCache {
    func getCachedInfoForRequest(_ request: URLRequest) -> CachedInfo
}

/**
 *  Stores responses in memory only and only if resp code was in range 200...299
 *  This is optimized for APIs that return ETag for every response, thus
 *  a repeated request can send over ETag in a header, allowing for not
 *  downloading data again. In the case of GitHub, such request doesn't count
 *  towards the rate limit.
 */
open class InMemoryURLCache: URLCache {
    
    fileprivate let storage = NSCache<NSString, AnyObject>()
    fileprivate let safe: Safe = CREW()
    
    public init(countLimit: Int = 1000) {
        self.storage.countLimit = countLimit //just to not grow indefinitely
    }
    
    open func getCachedInfoForRequest(_ request: URLRequest) -> CachedInfo {
        
        var responseInfo: ResponseInfo?
        let key = request.cacheableKey() as NSString
        self.safe.read {
            responseInfo = self.storage.object(forKey: key) as? ResponseInfo
        }
        
        let info = CachedInfo(responseInfo: responseInfo) { (responseInfo) -> () in
            self.safe.write {
                self.storage.setObject(responseInfo, forKey: key)
            }
        }
        return info
    }
}

extension URLRequest {
    public func cacheableKey() -> String {
        return "\(self.httpMethod!)-\(self.url!.absoluteString)"
    }
}

