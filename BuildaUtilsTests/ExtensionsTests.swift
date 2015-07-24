//
//  ExtensionsTests.swift
//  BuildaUtils
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import BuildaUtils

class ExtensionsTests: XCTestCase {

    // MARK: Array extension tests
    
    let xcode6 = [2015, 7, 23, 6, 47, 28]
    let xcode7 = [2015, 7, 23, 6, 47, 28, 845]
    
    func testAcceptingArrays() {
        XCTempAssertNoThrowError() {
            try self.xcode7.dateString()
            try self.xcode6.dateString()
        }
        
        XCTempAssertThrowsSpecificError(DateParsing.WrongNumberOfElements(4)) {
            try [1, 2, 3, 4].dateString()
        }
    }
    
    func testDateParsing() {
        XCTAssertEqual(try! xcode6.dateString(), "2015-07-23T06:47:28")
        XCTAssertEqual(try! xcode7.dateString(), "2015-07-23T06:47:28.845Z")
    }
    
}
