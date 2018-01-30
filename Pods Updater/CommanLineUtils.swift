//
//  CommanLineUtils.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

extension String {
    func run(completion: ((ProcessResult) -> Void)? = nil)  {
        let pipe = Pipe()
        let errorPipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = self.components(separatedBy: .whitespaces)
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        let fileHandle = pipe.fileHandleForReading
        let errorFileHandle = errorPipe.fileHandleForReading
        process.terminationHandler = { process in
            
            if process.terminationStatus == 0 {
                let output = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
                completion?(.success(output: output))
            } else {
                let output = String(data: errorFileHandle.readDataToEndOfFile(), encoding: .utf8)
                completion?(.error(output: output))
            }
        }
        
        process.launch()
        process.waitUntilExit()
    }
}

enum ProcessResult {
    case success(output: String?)
    case error(output: String?)
}
