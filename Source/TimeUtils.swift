//
//  TimeUtils.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/05/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public extension NSDate {
    
    public func nicelyFormattedRelativeTimeToNow() -> String {
        
        let relative = -1 * self.timeIntervalSinceNow
        let seconds = Int(relative)
        let formatted = TimeUtils.secondsToNaturalTime(seconds)
        return "\(formatted) ago"
    }
    
    class public func dateFromXCSString(date: String) -> NSDate? {
        // XCS date formatter
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.dateFromString(date)
    }
    
    class public func XCSStringFromDate(date: NSDate) -> String? {
        // XCS date formatter
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.stringFromDate(date)
    }
}

public class TimeUtils {
    
    //formats up to hours
    public class func secondsToNaturalTime(seconds: Int) -> String {
        
        let intSeconds = Int(seconds)
        let minutes = intSeconds / 60
        let remainderSeconds = intSeconds % 60
        let hours = minutes / 60
        let remainderMinutes = minutes % 60
        
        let formattedSeconds = "second".pluralizeStringIfNecessary(remainderSeconds)
        
        var result = "\(remainderSeconds) \(formattedSeconds)"
        if remainderMinutes > 0 {
            
            let formattedMinutes = "minute".pluralizeStringIfNecessary(remainderMinutes)
            result = "\(remainderMinutes) \(formattedMinutes) and " + result
        }
        if hours > 0 {
            
            let formattedHours = "hour".pluralizeStringIfNecessary(hours)
            result = "\(hours) \(formattedHours), " + result
        }
        return result
    }
    
}
