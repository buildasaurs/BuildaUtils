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
    
    enum TestError: Error {
        case one(String)
        case two(String)
    }
    
    // MARK: AvailabilityCheckState testing
    func testEqualityOfUncheckedStates() {
        XCTAssertEqual(AvailabilityCheckState.unchecked, AvailabilityCheckState.unchecked)
    }
    
    func testEqualityOfCheckingStates() {
        XCTAssertEqual(AvailabilityCheckState.checking, AvailabilityCheckState.checking)
    }
    
    func testEqualityOfFailedStates() {
        let error1 = TestError.one("foo") as NSError
        let error2 = TestError.one("bar") as NSError
        XCTAssertEqual(AvailabilityCheckState.failed(error1), AvailabilityCheckState.failed(error2))
    }
    
    func testInequalityOfFailedStates() {
        let error1 = TestError.one("") as NSError
        let error2 = TestError.two("") as NSError
        XCTAssertNotEqual(AvailabilityCheckState.failed(error1), AvailabilityCheckState.failed(error2))
    }
    
    func testEqualityOfSucceededStates() {
        XCTAssertEqual(AvailabilityCheckState.succeeded, AvailabilityCheckState.succeeded)
    }
    
    func testInequalityOfUncheckedAndSucceededStates() {
        XCTAssertNotEqual(AvailabilityCheckState.unchecked, AvailabilityCheckState.succeeded)
    }

}
