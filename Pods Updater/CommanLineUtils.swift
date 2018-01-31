//
//  CommanLineUtils.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

extension String {
    func run() -> ProcessResult {
        let pipe = Pipe()
        let errorPipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = self.components(separatedBy: .whitespaces)
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        let fileHandle = pipe.fileHandleForReading
        let errorFileHandle = errorPipe.fileHandleForReading
        
        process.launch()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            let output = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
            return .success(output: output)
        } else {
            let output = String(data: errorFileHandle.readDataToEndOfFile(), encoding: .utf8)
            return.error(output: output)
        }
    }
}

enum ProcessResult {
    case success(output: String?)
    case error(output: String?)
}
