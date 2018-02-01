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
                
                let trimmedLine = line.trimmingWhiteSpaces()
                if trimmedLine.isValidPodLine {
                    print(trimmedLine)
                    // Parse every line in the Podfile
                    let components = trimmedLine.components(separatedBy: "'")
                    if let name = components.second, let currentVersion = components.fourth {
                        
                        if currentVersion.first!.isDigit.not() { continue } // If this is not a valid version number
                        
                        var pod = Pod()
                        pod.lineIndex = index
                        pod.name = name
                        pod.currentVersion = currentVersion
                        
                        // Search for the pod locally
                        let result = "search \(pod.isSubSpec ? pod.specName : pod.name)".run()
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
                        case .error: continue
                        }
                        if pod.availableVersions.isNotEmpty {
                            if pods.contains(pod) {
                                pods[pods.index(of: pod)!].otherLineIndices.append(index)
                            } else {
                                pods.append(pod)
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
    
    func setVersion(_ version: String, forPod pod: Pod, inPodfile url: URL)  {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        
        var lines = content.splitByNewLines()
        
        // If we have the index for this Pod
        if lines.indices.contains(pod.lineIndex) {
            // Replace version in Podfile with new version
            lines[pod.lineIndex] = lines[pod.lineIndex].replacingFirstOccurrence(of: pod.currentVersion,
                                                                                 with: version)
            pod.otherLineIndices.forEach { index in
                // If this Pod exists in another line in this Podfile(maybe a diferrent target), update version as well
                if lines.indices.contains(index) {
                    lines[index] = lines[index].replacingFirstOccurrence(of: pod.currentVersion, with: version)
                }
            }
            
            // Write the new Podfile to disk
            let newString = lines.joinByNewLines()
            try? newString.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    
    func cleanUpPodfile(at url: URL) -> Single<PodFileCleanResult> {
        
        guard let podfileContent = try? String(contentsOf: url, encoding: .utf8) else {
            return Single.error(AppError("Could not parse selected file to string"))
        }

        guard let podfileLockContent = try? String(contentsOf: url.appendingPathExtension("lock"),
                                                   encoding: .utf8) else {
            return Single.error(AppError("No Podfile.lock file found in directory"))
        }
        
        return Single.create { observer -> Disposable in
            let disposable = BooleanDisposable()

            // Get the installed versions from Podfile.lock
            // 1. Parse Podfile.lock, and splt into array by lines
            // 2. Take lines until the DEPENDENCIES: line is reached
            // 3. Sort resulting lines by indentation so searching from zero index returns main Pod info first,
            //    before any pod dependency that has same name as the Pod we're searching for.
            // 3b. e.g  Podfile.lock:    - RxCocoa (4.1.1):
            //                               - RxSwift (~> 4.0)
            //                           - RxSwift (4.1.1)
            // We want the lines array sorted like ["- RxCocoa (4.1.1):", "- RxSwift (4.1.1)", "- RxSwift (~> 4.0)"]
            let installedPodsFromLock = podfileLockContent.splitByNewLines()
                .prefix(while: { $0.trimmingWhiteSpaces() != "DEPENDENCIES:" })
                .sorted { lhs, rhs -> Bool in
                    lhs.prefix(while: { $0 == " " }).count < rhs.prefix(while: { $0 == " " }).count
            }
            
            
            var lines = podfileContent.splitByNewLines()
            
            for (index, line) in lines.enumerated() {
                if disposable.isDisposed {
                    break
                }
                
                let trimmedLine = line.trimmingWhiteSpaces()
                if trimmedLine.isValidPodLine {
                    let components = trimmedLine.components(separatedBy: "'")
                    
                    // 1. If we have a Pod name,
                    // 2. If we can find a line matching same name in Podfile.lock
                    // 3. If we can find the version info in parentheses from the line in 2 above,
                    //    grab the pod version from within the parentheses, by dropping the parentheses symbols `()`
                    if let name = components.second,
                        let installedVersionInfo = installedPodsFromLock.first(where: { $0.contains(name) }),
                        let installedVersion = installedVersionInfo
                            .findMatches(forRegex: "\\((.*?)\\)")
                            .first?.dropFirst().dropLast() {
                        
                        // If this Pod is declared with a version. e.g - pod 'RxSwift', '~> 4.1.1',
                        // replace the verion info with a format supported by this app.
                        if let versionInfo = components.fourth,  versionInfo.isValidPodVersionInfo {
                            lines[index] = lines[index].replacingFirstOccurrence(of: versionInfo, with: String(installedVersion))
                            
                            // Else if this pod has no version information. e.g - pod 'RxSwift'
                            // just insert the version information.
                        } else if components.count < 4 {
                            
                            lines[index].insert(contentsOf: Array(", '\(installedVersion)'"),
                                                at: lines[index].endIndex(of: "'\(name)'")!)
                        }
                        
                    }
                }
            }
            if disposable.isDisposed.not() {
                observer(.success(PodFileCleanResult(url: url,
                                                     oldContent: podfileContent,
                                                     newContent: lines.joinByNewLines())))
            }
            return disposable
        }
    }
    
    func writePodfileData(_ data: String, toPodfile url: URL) -> Completable {
        return Completable.create { subscriber -> Disposable in
            do {
                try data.write(to: url, atomically: true, encoding: .utf8)
                subscriber(.completed)
            } catch {
                subscriber(.error(error))
            }
            
            return Disposables.create {  }
        }
    }
}

