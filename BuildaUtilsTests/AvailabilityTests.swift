//
//  AvailabilityTests.swift
//  BuildaUtils
//
//  Created by Honza Dvorsky on 10/3/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import BuildaUtils

class AvailabilityTests: XCTestCase {
    
    enum TestError: ErrorType {
        case One(String)
        case Two(String)
    }
    
    // MARK: AvailabilityCheckState testing
    func testEqualityOfUncheckedStates() {
        XCTAssertEqual(AvailabilityCheckState.Unchecked, AvailabilityCheckState.Unchecked)
    }
    
    func testEqualityOfCheckingStates() {
        XCTAssertEqual(AvailabilityCheckState.Checking, AvailabilityCheckState.Checking)
    }
    
    func testEqualityOfFailedStates() {
        let error1 = TestError.One("foo") as NSError
        let error2 = TestError.One("bar") as NSError
        XCTAssertEqual(AvailabilityCheckState.Failed(error1), AvailabilityCheckState.Failed(error2))
    }
    
    func testInequalityOfFailedStates() {
        let error1 = TestError.One("") as NSError
        let error2 = TestError.Two("") as NSError
        XCTAssertNotEqual(AvailabilityCheckState.Failed(error1), AvailabilityCheckState.Failed(error2))
    }
    
    func testEqualityOfSucceededStates() {
        XCTAssertEqual(AvailabilityCheckState.Succeeded, AvailabilityCheckState.Succeeded)
    }
    
    func testInequalityOfUncheckedAndSucceededStates() {
        XCTAssertNotEqual(AvailabilityCheckState.Unchecked, AvailabilityCheckState.Succeeded)
    }

}
