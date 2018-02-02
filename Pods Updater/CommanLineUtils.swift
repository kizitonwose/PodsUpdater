//
//  CommanLineUtils.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

enum Command {
    case updateRepo
    case search(podName: String)
    case install(podFileUrl: URL)
    
    var commandString : String {
        switch self {
        case .updateRepo: return "repo update"
        case let .search(podName): return "search \(podName)"
        case let .install(podFileUrl): return "install --project-directory=\(podFileUrl.path)"
        }
    }
}

extension Command {
    func run() -> ProcessResult {
        let pipe = Pipe()
        let errorPipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = self.commandString.components(separatedBy: .whitespaces)
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
    
    func run(withHandler outputHandler: @escaping (_ output: String) -> ()) {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = self.commandString.components(separatedBy: .whitespaces)
        process.standardOutput = pipe
        process.standardError = pipe
        
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                outputHandler(line)
            }
        }
        process.terminationHandler = { _ in
            fileHandle.readabilityHandler = nil
        }
        
        process.launch()
        process.waitUntilExit()
    }
}

enum ProcessResult {
    case success(output: String?)
    case error(output: String?)
}
