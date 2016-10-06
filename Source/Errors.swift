//
//  Errors.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 07/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum BuildaError: String {
    case UnknownError = "Unknown error"
}

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

public struct MyError: Error {
    
    public static func fromType(_ type: BuildaError) -> NSError {
        return self.withInfo(type.rawValue)
    }
    
    public static func withInfo(_ info: String?, internalError: NSError? = nil, userInfo: NSDictionary? = nil) -> NSError {
        var finalInfo: [AnyHashable: Any] = [:]
        
        if let info = info {
            finalInfo[NSLocalizedDescriptionKey] = info
        }
        
        if let internalError = internalError {
            finalInfo["encountered_error"] = internalError
        }
        
        if let userInfo = userInfo as? [AnyHashable: Any] {
            finalInfo = finalInfo.merged(with: userInfo)
        }
        
        return NSError(domain: "com.honzadvorsky.Buildasaur", code: 0, userInfo: finalInfo)
    }
}

struct StringError: Error {
    
    let description: String
    let _domain: String = ""
    let _code: Int = 0
    
    init(_ description: String) {
        self.description = description
    }
}
