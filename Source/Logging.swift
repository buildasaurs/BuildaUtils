//
//  Logging.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 12/04/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public protocol Logger {
    
    func description() -> String
    func log(message: String)
}

public class FileLogger: Logger {
    
    let fileURL: NSURL

    // Split log files at this byte size. If nil, never split files (default: 1MB)
    public var fileSizeCap: UInt64? = 1024 * 1024

    // If false, delete old log files when splitting on fileSizeCap
    public var shouldKeepArchivedLogs = true

    internal var stream: NSOutputStream
    internal var fileSize: UInt64? {
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(fileURL.path!) as NSDictionary
            return fileAttributes.fileSize()
        } catch {
            return nil
        }
    }

    lazy private var dateFormatter: NSDateFormatter = {
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        let formatter = NSDateFormatter()
        formatter.locale = enUSPosixLocale
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-SS"
        return formatter
    }()

    public init(fileURL: NSURL) {
        assert(fileURL.fileURL, "URL to log file has to be a File URL")
        self.fileURL = fileURL

        if !NSFileManager.defaultManager().fileExistsAtPath(fileURL.absoluteString) {
            NSFileManager.defaultManager().createFileAtPath(fileURL.absoluteString, contents: nil, attributes: nil)
        }

        self.stream = NSOutputStream(URL: fileURL, append: true)!
        self.stream.open()
    }

    deinit {
        self.stream.close()
    }

    public func description() -> String {
        return "File logger into file at path \(self.fileURL)"
    }
    
    public func log(message: String) {
        let data: NSData = "\(message)\n".dataUsingEncoding(NSUTF8StringEncoding)!

        if shouldArchiveFileBeforeLogging(data) {
            archiveLogFile()
        }

        self.stream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }

    internal func shouldArchiveFileBeforeLogging(data: NSData) -> Bool {
        guard let cap = self.fileSizeCap else {
            return false
        }

        guard let currentSize = self.fileSize else {
            return false
        }

        let sizeAfterWrite = currentSize + UInt64(data.length)
        return sizeAfterWrite > cap
    }


    private func archiveLogFile() {
        self.stream.close()

        let components = NSURLComponents(URL: fileURL, resolvingAgainstBaseURL: false)
        let dateString = dateFormatter.stringFromDate(NSDate())
        components!.path = components!.path?.stringByAppendingString(dateString)

        do {
            if self.shouldKeepArchivedLogs {
                try NSFileManager.defaultManager().moveItemAtURL(fileURL.filePathURL!, toURL: components!.URL!)
            } else {
                try NSFileManager.defaultManager().removeItemAtURL(fileURL.filePathURL!)
            }

            NSFileManager.defaultManager().createFileAtPath(fileURL.absoluteString, contents: nil, attributes: nil)
            self.stream = NSOutputStream(URL: fileURL, append: true)!
            self.stream.open()
        } catch let error {
            print(error)
        }
    }
}

public class ConsoleLogger: Logger {
    
    public  init() {
        //
    }
    
    public func description() -> String {
        return "Console logger"
    }
    
    public func log(message: String) {
        print(message)
    }
}

public class Log {
    
    static private var _loggers = [Logger]()
    public class func addLoggers(loggers: [Logger]) {
        for i in loggers {
            _loggers.append(i)
            print("Added logger: \(i)")
        }
    }
    
    private class func log(message: String) {
        for i in _loggers {
            i.log(message)
        }
    }
    
    public class func verbose(message: String) {
        Log.log("[VERBOSE]: " + message)
    }
    
    public class func info(message: String) {
        Log.log("[INFO]: " + message)
    }
    
    public class func error(error: ErrorType) {
        self.error("\(error)")
    }
    
    public class func error(message: String) {
        Log.log("[ERROR]: " + message)
    }
    
    public class func untouched(message: String) {
        Log.log(message)
    }
}
