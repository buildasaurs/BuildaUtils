
//  JSON.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 12/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public protocol JSONReadable {
    init(json: NSDictionary) throws
}

public protocol JSONWritable {
    func jsonify() -> NSDictionary
}

public enum JSONError: ErrorType {
    case valueNotFound(key: String)
    case unexpectedItemType(String)
}

public protocol JSONSerializable: JSONReadable, JSONWritable { }

public class JSON {

    private class func parseDictionary(data: NSData) -> ([String: AnyObject]?, NSError?) {
        let (object, error) = self.parse(data)
        return (object as? [String: AnyObject], error)
    }

    private class func parseArray(data: NSData) -> ([AnyObject]!, NSError!) {
        let (object, error) = self.parse(data)
        return (object as? [AnyObject], error)
    }
    
    public class func parse(url: NSURL) -> (AnyObject?, NSError?) {
        
        do {
            let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions(rawValue: 0))
            return self.parse(data)
        } catch {
            return (nil, error as NSError)
        }
    }
    
    public class func parse(data: NSData) -> (AnyObject?, NSError?) {
        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return (obj as AnyObject, nil)
        } catch {
            return (nil, error as NSError)
        }
    }
}

public extension NSDictionary {
    
    public func arrayForKey<T>(key: String) throws -> [T] {
        
        let array = try self.arrayForKey(key)
        var newArray: [T] = []
        for i in array {
            guard let t = i as? T else {
                throw JSONError.unexpectedItemType(String(i.dynamicType))
            }
            newArray.append(t)
        }
        return newArray
    }
    
    public func optionalForKey<Z>(key: String) -> Z? {
        
        if let optional = self[key] as? Z {
            return optional
        }
        return nil
    }

    public func nonOptionalForKey<Z>(key: String) throws -> Z {
        guard let item: Z = self.optionalForKey(key) else {
            throw JSONError.valueNotFound(key: key)
        }
        return item
    }
    
    public func optionalArrayForKey(key: String) -> NSArray? {
        return self.optionalForKey(key)
    }
    
    public func arrayForKey(key: String) throws -> NSArray {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalStringForKey(key: String) -> String? {
        return self.optionalForKey(key)
    }
    
    public func optionalNSURLForKey(key: String) -> NSURL? {
        if let string = self.optionalStringForKey(key) {
            return NSURL(string: string)
        }
        return nil
    }

    public func stringForKey(key: String) throws -> String {
        return try self.nonOptionalForKey(key)
    }

    public func optionalIntForKey(key: String) -> Int? {
        return self.optionalForKey(key)
    }

    public func intForKey(key: String) throws -> Int {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalBoolForKey(key: String) -> Bool? {
        return self.optionalForKey(key)
    }

    public func boolForKey(key: String) throws -> Bool {
        return try self.nonOptionalForKey(key)
    }
    
    public func optionalDictionaryForKey(key: String) -> NSDictionary? {
        return self.optionalForKey(key)
    }

    public func dictionaryForKey(key: String) throws -> NSDictionary {
        return try self.nonOptionalForKey(key)
    }

    public func optionalDateForKey(key: String) -> NSDate? {
        
        if let dateString = self.optionalStringForKey(key) {
            let date = NSDate.dateFromXCSString(dateString)
            return date
        }
        return nil
    }

    public func dateForKey(key: String) throws -> NSDate {
        guard let item = self.optionalDateForKey(key) else {
            throw JSONError.valueNotFound(key: key)
        }
        return item
    }
    
    public func optionalDoubleForKey(key: String) -> Double? {
        return self.optionalForKey(key)
    }

    public func doubleForKey(key: String) throws -> Double {
        return try self.nonOptionalForKey(key)
    }
    
}

public extension NSMutableDictionary {
    
    public func optionallyAddValueForKey(value: AnyObject?, key: String) {
        if let value: AnyObject = value {
            self[key] = value
        }
    }
}

