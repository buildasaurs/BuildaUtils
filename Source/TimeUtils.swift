//
//  TimeUtils.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/05/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public extension Date {
    
    public func nicelyFormattedRelativeTimeToNow() -> String {
        
        let relative = -1 * self.timeIntervalSinceNow
        let seconds = Int(relative)
        let formatted = TimeUtils.secondsToNaturalTime(seconds)
        return "\(formatted) ago"
    }
    
    static public func dateFromXCSString(_ date: String) -> Date? {
        // XCS date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.date(from: date)
    }
    
    static public func XCSStringFromDate(_ date: Date) -> String? {
        // XCS date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.string(from: date)
    }
}

open class TimeUtils {
    
    //formats up to hours
    open class func secondsToNaturalTime(_ seconds: Int) -> String {
        
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
