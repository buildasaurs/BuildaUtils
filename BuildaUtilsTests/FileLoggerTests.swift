//
//  FileLoggerTests.swift
//  BuildaUtils
//
//  Created by Joel Ekström on 2016-01-16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import BuildaUtils

class FileLoggerTests: XCTestCase {

    let fileSizeCap = 1000 as UInt64
    var logger: FileLogger!
    var logFileURL: URL!
    
    override func setUp() {
        super.setUp()

        let directoryPath = createUniqueTemporaryDirectory()!
        self.logFileURL = directoryPath.appendingPathComponent("test.log")
        self.logger = FileLogger(fileURL: self.logFileURL)
        self.logger.fileSizeCap = fileSizeCap
    }

    func testFileSizeCounter() {
        let message = "Testing to write something to the log!"
        let message2 = "Writing something more"

        let messageSize = "\(message)\n".data(using: String.Encoding.utf8)!.count
        let message2Size = "\(message2)\n".data(using: String.Encoding.utf8)!.count
        let totalSize = messageSize + message2Size

        self.logger.log(message)
        XCTAssertEqual(self.logger.fileSize, UInt64(messageSize))

        self.logger.log(message2)
        XCTAssertEqual(self.logger.fileSize, UInt64(totalSize))

        // Create new logger to test that reading initial file size works
        self.logger.stream.close()
        self.logger = FileLogger(fileURL: self.logFileURL)
        XCTAssertEqual(self.logger.fileSize, UInt64(totalSize))
    }

    func testFileArchiving() {
        let message = "Testing to write something to the log!"
        let messageSize = UInt64("\(message)\n".data(using: String.Encoding.utf8)!.count)

        var sizeCounter = 0 as UInt64
        while true {
            if self.logger.fileSize! + messageSize < fileSizeCap {
                self.logger.log(message)
                sizeCounter = sizeCounter + messageSize
            } else {
                break
            }
        }

        XCTAssertEqual(self.logger.fileSize, sizeCounter)
        self.logger.log(message)
        XCTAssertEqual(self.logger.fileSize, messageSize)
    }

    func createUniqueTemporaryDirectory() -> URL? {
        let template = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("buildautils-test-XXXXXX") as NSURL
        
        // Fill buffer with a C string representing the local file system path.
        var buffer = [Int8](repeating: 0, count: Int(PATH_MAX))
        template.getFileSystemRepresentation(&buffer, maxLength: buffer.count)

        // Create unique file name (and open file):
        let fd = mkdtemp(&buffer)
        if fd != nil {
            return URL(fileURLWithFileSystemRepresentation: buffer, isDirectory: false, relativeTo: nil)
        } else {
            print("Error: " + String(describing: strerror(errno)))
            return nil
        }
    }
}
