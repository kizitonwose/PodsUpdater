//
//  CommanLine.swift
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

    var arguments: [String] {
        switch self {
        case .updateRepo: return ["repo", "update"]
        case let .search(podName): return  ["search", "--simple", "--no-pager", "--no-ansi", "\(podName)"]
        case let .install(podFileUrl): return  ["install", "--project-directory=\(podFileUrl.path)"]
        }
    }    
}

extension Command {
    
    @discardableResult
    func run(withHandler outputHandler: ((_ output: String) -> ())? = nil) -> ProcessResult {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = arguments
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        if outputHandler != nil {
            
            outputPipe.fileHandleForReading.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    outputHandler?(line)
                }
            }
            
            errorPipe.fileHandleForReading.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: .utf8) {
                    outputHandler?(line)
                }
            }
            
            process.terminationHandler = { _ in
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
            }
        }
        
        process.launch()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            return .success(output: output)
        } else {
            let output = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            return.error(error: ProcessResult.ProcessError(status: Int(process.terminationStatus), output: output))
        }
    }
    
}

enum ProcessResult {
    case success(output: String?)
    case error(error: ProcessError)
    
    struct ProcessError: Error {
        let status: Int
        let output: String?
    }
}
