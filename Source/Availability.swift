//
//  Availability.swift
//  BuildaUtils
//
//  Created by Honza Dvorsky on 10/3/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum AvailabilityCheckState: Equatable {
    case unchecked
    case checking
    case failed(Error?)
    case succeeded
    
    public func isDone() -> Bool {
        return self != .checking
    }
}

/// Added `Equatable` to the enum to better test properties of this enum.
public func == (a:AvailabilityCheckState, b:AvailabilityCheckState) -> Bool {
    switch(a,b) {
    case (.unchecked, .unchecked) : return true
    case (.checking, .checking) : return true
    case (.failed(let fa), .failed(let fb)) :
        let nsA = (fa as? NSError)
        let nsB = (fb as? NSError)
        return nsA == nsB
    case (.succeeded, .succeeded) : return true
    default: return false
    }
}
