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
    
    func parsePodfile(at url: URL, onlyNewVersions: Bool) -> Observable<ProgressResult<[Pod]>> {
        print(getProjectNameForPodfile(at: url))
        var content = ""
        do {// Read the file to String
           content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            return Observable.error(error)
        }

       return Observable.create { observer -> Disposable in
        let disposable = BooleanDisposable()
        
        let lines = content.splitByNewLines()
        
        var pods = [Pod]()
        
        for (index, line) in lines.enumerated() {
            if disposable.isDisposed {
                break
            }
           
            let progress = Double(index)/(Double(lines.count - 1)) * 100.0
            observer.onNext(ProgressResult(progress: progress, result: nil))
            
            
            let line = line.trimmingWhiteSpaces()
            if line.isValidPodLine {
        
                print(line)
                let components = line.components(separatedBy: "'") // Parse every line in the Podfile
                if let name = components.second, let currentVersion = components.fourth {
                    var pod = Pod()
                    pod.lineNumber = index
                    pod.name = name
                    pod.currentVersion = currentVersion
                    
                    // Search for the pod locally
                    "search \(pod.isSubSpec ? pod.specName : pod.name)".run() { result in
                        switch result {
                        case .success(let output):
                            // Find the line in search result with version information
                            let outputLines = output!.splitByNewLines()
                            let versionsLine = outputLines.first {
                                $0.trimmingWhiteSpaces().starts(with: "- Versions:")
                            }
                            
                            if let versionsLine = versionsLine {
                                // Remove uneccessary information from the version line and retrieve pod versions
                                var versions = versionsLine
                                    .replacingOccurrences(of: "- Versions:", with: "")
                                    .replacingOccurrences(of: "[master repo]", with: "")
                                    .splitByComma()
                                    .map { $0.trimmingWhiteSpaces() }
                                // print(versions)
                                
                                // If the user chose to see only newer versions of their pods than currently
                                // installed, we remove all older versions from the array.
                                if onlyNewVersions, let currentVersionIndex = versions.index(of: pod.currentVersion) {
                                    versions = Array(versions.dropLast(versions.count-currentVersionIndex))
                                }
                                pod.availableVersions = versions
                            }
                        case .error: break
                        }
                        if pod.availableVersions.isNotEmpty {
                            if pods.contains(pod) {
                                pods[pods.index(of: pod)!].otherLineNumbers.append(index)
                            } else {
                                pods.append(pod)
                            }
                        }
                    }
                }
                
            }
        }
        
        if disposable.isDisposed.not() {
            observer.onNext(ProgressResult(progress: 100, result: pods))
            observer.onCompleted()
        }
        return disposable
        }
        
    }
    
    func getProjectNameForPodfile(at url: URL) -> String {
        let fileManager = FileManager.default
        let filesInFolder = try? fileManager.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
        
        if let filesInFolder = filesInFolder, filesInFolder.isNotEmpty {
            // Get the xcworkspace/xcodeproj directories
            let projectDirectory = filesInFolder.first{ $0.hasSuffix(".xcworkspace") } ?? filesInFolder.first{ $0.hasSuffix(".xcodeproj") }
            
            if let projectDirectory = projectDirectory {
                // Remove xcworkspace/xcodeproj suffix
                return projectDirectory
                    .components(separatedBy: ".")
                    .dropLast()
                    .joined(separator: ".")
            }
        }
        return url.path
    }

}

