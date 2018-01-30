//
//  Repository.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class Repository: DataSource {

    public static let instance = Repository()

    private init() { }
    
    func parsePodfile(at path: URL) -> Single<[Pod]> {
        var content = ""
        do {// Read the file to String
           content = try String(contentsOf: path, encoding: .utf8)
        } catch {
            return Single.error(error)
        }

        return Single.create(subscribe: { single -> Disposable in
            
            let disposable = BooleanDisposable()
            
            let lines = content.splitByNewLines()
            
            var pods = [Pod]()
            
            for (index, line) in lines.enumerated() {
                let line = line.trimmingWhiteSpaces()
                if line.isValidPodLine {
                    if disposable.isDisposed {
                        break
                    }
                    print(line)
                    let components = line.components(separatedBy: "'") // Parse every line in the Podfile
                    if let name = components.second, let currentVersion = components.fourth {
                        var pod = Pod()
                        pod.lineNumber = index
                        pod.name = name
                        pod.currentVersion = currentVersion
                        
                        // Search for the pod locally
                        "search \(pod.name)".run() { result in
                            switch result {
                            case .success(let output):
                                // Find the line in search result with version information
                                let outputLines = output!.splitByNewLines()
                                let versionsLine = outputLines.first {
                                    $0.trimmingWhiteSpaces().starts(with: "- Versions:")
                                }
                                
                                var availableVersions = [String]()
                                if let versionsLine = versionsLine {
                                    // Remove uneccessary information from the version line and retrieve pod versions
                                    let versions = versionsLine
                                        .replacingOccurrences(of: "- Versions:", with: "")
                                        .replacingOccurrences(of: "[master repo]", with: "")
                                        .splitByComma()
                                        .map { $0.trimmingWhiteSpaces() }
                                    // print(versions)
                                    availableVersions.append(contentsOf: versions)
                                }
                                pod.availableVersions = availableVersions
                            case .error: break
                            }
                            pods.append(pod)
                        }
                    }
                    
                }
            }
            
            single(.success(pods))
            
            return disposable
        })
    }

}

