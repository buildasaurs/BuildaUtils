//
//  Availability.swift
//  BuildaUtils
//
//  Created by Honza Dvorsky on 10/3/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum AvailabilityCheckState: Equatable {
    case Unchecked
    case Checking
    case Failed(ErrorType?)
    case Succeeded
    
    public func isDone() -> Bool {
        return self != .Checking
    }
}

/// Added `Equatable` to the enum to better test properties of this enum.
public func == (a:AvailabilityCheckState, b:AvailabilityCheckState) -> Bool {
    switch(a,b) {
    case (.Unchecked, .Unchecked) : return true
    case (.Checking, .Checking) : return true
    case (.Failed(let fa), .Failed(let fb)) :
        let nsA = (fa as? NSError)
        let nsB = (fb as? NSError)
        return nsA == nsB
    case (.Succeeded, .Succeeded) : return true
    default: return false
    }
}
