//
//  Extensions.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 03/05/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public func unthrow<R>(_ block: () throws -> R) -> (R?, Error?) {
    do {
        return (try block(), nil)
    } catch {
        return (nil, error)
    }
}

public func unthrow<R>(_ block: () throws -> R) -> (R?, NSError?) {
    do {
        return (try block(), nil)
    } catch {
        return (nil, error as NSError)
    }
}

public extension Double {
    
    public func clipTo(_ numberOfDigits: Int) -> Double {
        
        let multiplier = pow(10.0, Double(numberOfDigits))
        return Double(Int(self * multiplier)) / multiplier
    }
}

public extension String {
    
    public func stripTrailingNewline() -> String {
        
        var stripped = self
        if stripped.hasSuffix("\n") {
            stripped.remove(at: stripped.characters.index(before: stripped.endIndex))
        }
        return stripped
    }
    
    public func pluralizeStringIfNecessary(_ number: Int) -> String {
        if number > 1 {
            return "\(self)s"
        }
        return self
    }
}

public enum DateParsingError: Error {
    case wrongNumberOfElements(Int)
}

public extension Array where Element: Integer {
    
    public func dateString() throws -> String {
        let elementsCount = self.count
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        let formattedSelf = self.flatMap { formatter.string(from: $0 as! NSNumber) }
        
        switch elementsCount {
        case 6:
            return "\(formattedSelf[0])-\(formattedSelf[1])-\(formattedSelf[2])T\(formattedSelf[3]):\(formattedSelf[4]):\(formattedSelf[5])"
        case 7:
            return "\(formattedSelf[0])-\(formattedSelf[1])-\(formattedSelf[2])T\(formattedSelf[3]):\(formattedSelf[4]):\(formattedSelf[5]).\(formattedSelf[6])Z"
        default:
            throw DateParsingError.wrongNumberOfElements(elementsCount)
        }
    }
    
}
