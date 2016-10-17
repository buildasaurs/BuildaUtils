
//  JSON.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 12/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public protocol JSONReadable {
    init(json: [String: Any]) throws
}

public protocol JSONWritable {
    func jsonify() -> [String: Any]
}

public enum JSONError: Error {
    case valueNotFound(key: String)
    case unexpectedItemType(String)
}

public protocol JSONSerializable: JSONReadable, JSONWritable { }

open class JSON {

    fileprivate class func parseDictionary(_ data: Data) -> ([String: AnyObject]?, NSError?) {
        let (object, error) = self.parse(data)
        return (object as? [String: AnyObject], error)
    }

    fileprivate class func parseArray(_ data: Data) -> ([AnyObject]?, NSError?) {
        let (object, error) = self.parse(data)
        return (object as? [AnyObject], error)
    }
    
    open class func parse(_ url: URL) -> (AnyObject?, NSError?) {
        
        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions(rawValue: 0))
            return self.parse(data)
        } catch {
            return (nil, error as NSError)
        }
    }
    
    open class func parse(_ data: Data) -> (AnyObject?, NSError?) {
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return (obj as AnyObject, nil)
        } catch {
            return (nil, error as NSError)
        }
    }
}

public extension NSDictionary {
    
    public func arrayForKey<T>(_ key: String) throws -> [T] {
        
        let array = try self.arrayForKey(key)
        var newArray: [T] = []
        for i in array {
            guard let t = i as? T else {
                throw JSONError.unexpectedItemType(String(describing: type(of: (i))))
            }
            newArray.append(t)
        }
        return newArray
    }
    
    public func optionalForKey<Z>(_ key: String) -> Z? {
        
        if let optional = self[key] as? Z {
            return optional
        }
        return nil
    }

    public func nonOptionalForKey<Z>(_ key: String) throws -> Z {
        guard let item: Z = self.optionalForKey(key) else {
            throw JSONError.valueNotFound(key: key)
        }
        return item
    }
    
    public func optionalArrayForKey(_ key: String) -> NSArray? {
        return self.optionalForKey(key)
    }
    
    public func arrayForKey(_ key: String) throws -> NSArray {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalStringForKey(_ key: String) -> String? {
        return self.optionalForKey(key)
    }
    
    public func optionalNSURLForKey(_ key: String) -> URL? {
        if let string = self.optionalStringForKey(key) {
            return URL(string: string)
        }
        return nil
    }

    public func stringForKey(_ key: String) throws -> String {
        return try self.nonOptionalForKey(key)
    }

    public func optionalIntForKey(_ key: String) -> Int? {
        return self.optionalForKey(key)
    }

    public func intForKey(_ key: String) throws -> Int {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalBoolForKey(_ key: String) -> Bool? {
        return self.optionalForKey(key)
    }

    public func boolForKey(_ key: String) throws -> Bool {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalDictionaryForKey(_ key: String) -> NSDictionary? {
        return self.optionalForKey(key)
    }

    public func dictionaryForKey(_ key: String) throws -> NSDictionary {
        return try self.nonOptionalForKey(key)
    }

    public func optionalDateForKey(_ key: String) -> Date? {
        
        if let dateString = self.optionalStringForKey(key) {
            let date = Date.dateFromXCSString(dateString)
            return date
        }
        return nil
    }

    public func dateForKey(_ key: String) throws -> Date {
        guard let item = self.optionalDateForKey(key) else {
            throw JSONError.valueNotFound(key: key)
        }
        return item
    }
    
    public func optionalDoubleForKey(_ key: String) -> Double? {
        return self.optionalForKey(key)
    }

    public func doubleForKey(_ key: String) throws -> Double {
        return try self.nonOptionalForKey(key)
    }
    
}

public extension NSMutableDictionary {
    
    public func optionallyAddValueForKey(_ value: AnyObject?, key: String) {
        if let value: AnyObject = value {
            self[key] = value
        }
    }
}

