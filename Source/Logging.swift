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
    func log(_ message: String)
}

open class FileLogger: Logger {
    
    let fileURL: URL

    // Split log files at this byte size. If nil, never split files (default: 1MB)
    open var fileSizeCap: UInt64? = 1024 * 1024

    // If false, delete old log files when splitting on fileSizeCap
    open var shouldKeepArchivedLogs = true

    internal var stream: OutputStream
    internal var fileSize: UInt64? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path) as NSDictionary
            return fileAttributes.fileSize()
        } catch {
            return nil
        }
    }

    lazy fileprivate var dateFormatter: DateFormatter = {
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        let formatter = DateFormatter()
        formatter.locale = enUSPosixLocale
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-SS"
        return formatter
    }()

    public init(fileURL: URL) {
        assert(fileURL.isFileURL, "URL to log file has to be a File URL")
        self.fileURL = fileURL

        if !FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            FileManager.default.createFile(atPath: fileURL.absoluteString, contents: nil, attributes: nil)
        }

        self.stream = OutputStream(url: fileURL, append: true)!
        self.stream.open()
    }

    deinit {
        self.stream.close()
    }

    open func description() -> String {
        return "File logger into file at path \(self.fileURL)"
    }
    
    open func log(_ message: String) {
        let data: Data = "\(message)\n".data(using: String.Encoding.utf8)!

        if shouldArchiveFileBeforeLogging(data) {
            archiveLogFile()
        }

        self.stream.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
    }

    internal func shouldArchiveFileBeforeLogging(_ data: Data) -> Bool {
        guard let cap = self.fileSizeCap else {
            return false
        }

        guard let currentSize = self.fileSize else {
            return false
        }

        let sizeAfterWrite = currentSize + UInt64(data.count)
        return sizeAfterWrite > cap
    }


    fileprivate func archiveLogFile() {
        self.stream.close()

        var components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false)
        let dateString = dateFormatter.string(from: Date())
        components!.path = (components!.path) + dateString

        do {
            if self.shouldKeepArchivedLogs {
                try FileManager.default.moveItem(at: fileURL, to: components!.url!)
            } else {
                try FileManager.default.removeItem(at: fileURL)
            }

            FileManager.default.createFile(atPath: fileURL.absoluteString, contents: nil, attributes: nil)
            self.stream = OutputStream(url: fileURL, append: true)!
            self.stream.open()
        } catch let error {
            print(error)
        }
    }
}

open class ConsoleLogger: Logger {
    
    public  init() {
        //
    }
    
    open func description() -> String {
        return "Console logger"
    }
    
    open func log(_ message: String) {
        print(message)
    }
}

open class Log {
    
    static fileprivate var _loggers = [Logger]()
    open class func addLoggers(_ loggers: [Logger]) {
        for i in loggers {
            _loggers.append(i)
            print("Added logger: \(i)")
        }
    }
    
    fileprivate class func log(_ message: String) {
        for i in _loggers {
            i.log(message)
        }
    }
    
    open class func verbose(_ message: String) {
        Log.log("[VERBOSE]: " + message)
    }
    
    open class func info(_ message: String) {
        Log.log("[INFO]: " + message)
    }
    
    open class func error(_ error: Error) {
        self.error("\(error)")
    }
    
    open class func error(_ message: String) {
        Log.log("[ERROR]: " + message)
    }
    
    open class func untouched(_ message: String) {
        Log.log(message)
    }
}
