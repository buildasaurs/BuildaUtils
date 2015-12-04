//
//  Extensions.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 03/05/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public extension Double {
    
    public func clipTo(numberOfDigits: Int) -> Double {
        
        let multiplier = pow(10.0, Double(numberOfDigits))
        return Double(Int(self * multiplier)) / multiplier
    }
}

public extension String {
    
    public func stripTrailingNewline() -> String {
        
        var stripped = self
        if stripped.hasSuffix("\n") {
            stripped.removeAtIndex(stripped.endIndex.predecessor())
        }
        return stripped
    }
    
    public func pluralizeStringIfNecessary(number: Int) -> String {
        if number > 1 {
            return "\(self)s"
        }
        return self
    }
}

public enum DateParsingError: ErrorType {
    case WrongNumberOfElements(Int)
}

public extension Array where Element: IntegerType {
    
    public func dateString() throws -> String {
        let elementsCount = self.count
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        let formattedSelf = self.flatMap { formatter.stringFromNumber($0 as! NSNumber) }
        
        switch elementsCount {
        case 6:
            return "\(formattedSelf[0])-\(formattedSelf[1])-\(formattedSelf[2])T\(formattedSelf[3]):\(formattedSelf[4]):\(formattedSelf[5])"
        case 7:
            return "\(formattedSelf[0])-\(formattedSelf[1])-\(formattedSelf[2])T\(formattedSelf[3]):\(formattedSelf[4]):\(formattedSelf[5]).\(formattedSelf[6])Z"
        default:
            throw DateParsingError.WrongNumberOfElements(elementsCount)
        }
    }
    
}