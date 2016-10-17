//
//  Script.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 12/05/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

/**
*   A utility class for running terminal Scripts from your Mac app.
*/

#if os(OSX)

open class Script {
    
    public typealias ScriptResponse = (terminationStatus: Int, standardOutput: String, standardError: String)
    
    /**
    *   Run a script by passing in a name of the script (e.g. if you use just 'git', it will first
    *   resolve by using the 'git' at path `which git`) or the full path (such as '/usr/bin/git').
    *   Optional arguments are passed in as an array of Strings and an optional environment dictionary
    *   as a map from String to String.
    *   Back you get a 'ScriptResponse', which is a tuple around the termination status and outputs (standard and error).
    */
    open class func run(_ name: String, arguments: [String] = [], environment: [String: String] = [:]) -> ScriptResponse {
        
        //first resolve the name of the script to a path with `which`
        let resolved = self.runResolved("/usr/bin/which", arguments: [name], environment: [:])
        
        //which returns the path + \n, so strip the newline
        let path = resolved.standardOutput.stripTrailingNewline()
        
        //if resolving failed, just abort and propagate the failed run up
        if (resolved.terminationStatus != 0) || path.isEmpty {
            return resolved
        }
        
        //ok, we have a valid path, run the script
        let result = self.runResolved(path, arguments: arguments, environment: environment)
        return result
    }
    
    /**
    *   An alternative to Script.run is Script.runInTemporaryScript, which first dumps the passed in script
    *   string into a temporary file, runs it and then deletes it. More useful for more complex script that involve
    *   piping data between multiple scripts etc. Might be slower than Script.run, however.
    */
    open class func runTemporaryScript(_ script: String) -> ScriptResponse {
        
        var resp: ScriptResponse!
        self.runInTemporaryScript(script, block: { (scriptPath, error) -> () in
            resp = Script.run("/bin/bash", arguments: [scriptPath])
        })
        return resp
    }
    
    fileprivate class func runInTemporaryScript(_ script: String, block: (_ scriptPath: String, _ error: NSError?) -> ()) {
        
        let uuid = UUID().uuidString
        // Bug? https://forums.developer.apple.com/thread/13580
        let tempPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(uuid)
        
        do {
            //write the script to file
            try script.write(toFile: tempPath, atomically: true, encoding: String.Encoding.utf8)
            
            block(tempPath, nil)
            
            //delete the temp script
            try FileManager.default.removeItem(atPath: tempPath)
        } catch {
            Log.error(error)
        }
    }
    
    fileprivate class func runResolved(_ path: String, arguments: [String], environment: [String: String]) -> ScriptResponse {
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        let outputFile = outputPipe.fileHandleForReading
        let errorFile = errorPipe.fileHandleForReading
        
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        
        var env = ProcessInfo.processInfo.environment
        for (_, keyValue) in environment.enumerated() {
            env[keyValue.0] = keyValue.1
        }
        task.environment = env
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        task.launch()
        task.waitUntilExit()
        
        let terminationStatus = Int(task.terminationStatus)
        let output = self.stringFromFileAndClose(outputFile)
        let error = self.stringFromFileAndClose(errorFile)
        
        return (terminationStatus, output, error)
    }
    
    fileprivate class func stringFromFileAndClose(_ file: FileHandle) -> String {
        
        let data = file.readDataToEndOfFile()
        file.closeFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        return output ?? ""
    }
}

#endif
