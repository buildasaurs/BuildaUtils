//
//  TestUtils.swift
//  BuildaUtils
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest

// MARK: Exception assertions
// Based on: https://forums.developer.apple.com/thread/5824
extension XCTestCase {
    /**
    Replacement method for XCTAssertThrowsError which isn't currently supported.
    
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertThrowsError(message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
            
            let msg = (message == "") ? "Tested block did not throw error as expected." : message
            XCTFail(msg, file: file, line: line)
        } catch {}
    }
    
    /**
    Replacement method for XCTAssertThrowsSpecificError which isn't currently supported.
    
    - parameter kind:    ErrorType which is expected to be thrown from block
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertThrowsSpecificError(kind: ErrorType, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
            
            let msg = (message == "") ? "Tested block did not throw expected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        } catch let error as NSError {
            let expected = kind as NSError
            if ((error.domain != expected.domain) || (error.code != expected.code)) {
                let msg = (message == "") ? "Tested block threw \(error), not expected \(kind) error." : message
                XCTFail(msg, file: file, line: line)
            }
        }
    }
    
    /**
    Replacement method for XCTAssertNoThrowsError which isn't currently supported.
    
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertNoThrowError(message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
        } catch {
            let msg = (message == "") ? "Tested block threw unexpected error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
    
    /**
    Replacement method for XCTAssertNoThrowsSpecificError which isn't currently supported.
    
    - parameter kind:    ErrorType which isn't expected to be thrown from block
    - parameter message: Message which should be displayed
    - parameter file:    File in which assertion happened
    - parameter line:    Line in which assertion happened
    - parameter block:   Block of code against which assertion should be matched
    */
    func XCTempAssertNoThrowSpecificError(kind: ErrorType, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
        do {
            try block()
        } catch let error as NSError {
            let unwanted = kind as NSError
            if ((error.domain == unwanted.domain) && (error.code == unwanted.code)) {
                let msg = (message == "") ? "Tested block threw unexpected \(kind) error." : message
                XCTFail(msg, file: file, line: line)
            }
        }
    }
}