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
    
    func findVersionsForPodfile(at url: URL) -> Observable<ProgressResult<PodfileVersionCheckResult>> {
        
        return Observable.create { observer -> Disposable in
            let disposable = BooleanDisposable()
            
            var content = ""
            do {// Read the file to String
                content = try String(contentsOf: url, encoding: .utf8)
            } catch {
                observer.onError(error)
                observer.onCompleted()
                return disposable
            }
            
            let lines = content.splitByNewLines()
            
            var pods = [Pod]()
            var hasPodWithUnsupportedFormat = false

            for (index, line) in lines.enumerated() {
                if disposable.isDisposed { break }
                
                let progress = Double(index)/(Double(lines.count - 1)) * 100.0
                observer.onNext(ProgressResult(progress: progress, result: nil))
                
                let trimmedLine = line.trimmingWhiteSpaces()
                if trimmedLine.isValidPodLine {

                    // Parse every line in the Podfile
                    let components = trimmedLine.components(separatedBy: "'")
                    if let name = components.second, let currentVersion = components.fourth {
                        
                        // If this version info has any of the magic operators, add info message and skip this index.
                        if currentVersion.isUnsupportedPodVersionInfo {
                            hasPodWithUnsupportedFormat = true
                            continue
                        }
                        
                        var pod = Pod()
                        pod.lineIndex = index
                        pod.name = name
                        pod.currentVersion = currentVersion
                        
                        // Search for the pod locally
                        let result = Command.search(podName: pod.isSubSpec ? pod.specName : pod.name).run()
                        switch result {
                        case .success(let output):
                            // Find the line in search result with version information
                            let outputLines = output!.splitByNewLines()
                            let versionsLine = outputLines.first {
                                $0.trimmingWhiteSpaces().starts(with: "- Versions:")
                            }
                            
                            if let versionsLine = versionsLine {
                                // Remove unnecessary information from the version line and retrieve pod versions
                                let versions = versionsLine
                                    .replacingOccurrences(of: "- Versions:", with: "")
                                    .replacingOccurrences(of: "[master repo]", with: "")
                                    .splitByComma()
                                    .map { $0.trimmingWhiteSpaces() }
                                
                                pod.allVersions = versions
                            }
                            
                            if let homepageUrlLine = outputLines.first(where: { $0.trimmingWhiteSpaces().starts(with: "- Homepage:") }) {
                                let homepageUrlString = homepageUrlLine.replacingOccurrences(of: "- Homepage:", with: "").trimmingWhiteSpaces()
                                pod.homepageUrl = URL(string: homepageUrlString)
                            }
                        case .error: continue
                        }
                        if pod.allVersions.isNotEmpty {
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
                let sortedPods = pods.sorted { $0.name.compare($1.name) == .orderedAscending }
                observer.onNext(ProgressResult(progress: 100, result: PodfileVersionCheckResult(pods: sortedPods,
                                                                                                hasPodWithUnsupportedFormat: hasPodWithUnsupportedFormat)))
                observer.onCompleted()
            }
            return disposable
        }
        
    }
    
    func getProjectNameForPodfile(at url: URL) -> String {
        let fileManager = FileManager.default
        let filesInFolder = try? fileManager.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
        
        if let filesInFolder = filesInFolder, filesInFolder.isNotEmpty {
            // Get the xcworkspace or xcodeproj directories
            let projectDirectory = filesInFolder.first{ $0.hasSuffix(".xcworkspace") } ??
                filesInFolder.first{ $0.hasSuffix(".xcodeproj") }
            
            if let projectDirectory = projectDirectory {
                // Remove xcworkspace or xcodeproj suffix
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
                // If this Pod exists in another line in this Podfile(maybe a different target), update version as well
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

        return Single.create { observer -> Disposable in
            let disposable = BooleanDisposable()
            
            guard let podfileContent = try? String(contentsOf: url, encoding: .utf8) else {
                observer(.error(AppError(reason: "Could not parse selected file to string")))
                return disposable
            }
            
            // Attempt to read Podfile.lock file in project directory.
            let podfileLockUrl = url.appendingPathExtension("lock")
            guard let podfileLockContent = try? String(contentsOf: podfileLockUrl, encoding: .utf8) else {
                observer(.error(AppError(reason: "No Podfile.lock file found in directory")))
                return disposable
            }
            

            // Get the installed versions from Podfile.lock
            // 1. Parse Podfile.lock, and splt into array by lines
            // 2. Take lines until the DEPENDENCIES: line is reached
            // 3. Filter out lines without an indentation of of 2,
            //    this removes all Pod internal depencies(they have indentaion count of 4)
            // 3b. e.g  Podfile.lock:    - RxCocoa (4.1.1):
            //                               - RxSwift (~> 4.0)
            //                           - RxSwift (4.1.1)
            // We only want the lines - RxCocoa (4.1.1): and - RxSwift (4.1.1)
            let installedPodsFromLock = Array(podfileLockContent.splitByNewLines()
                .prefix(while: { $0.trimmingWhiteSpaces() != "DEPENDENCIES:" }))
                .filter({ $0.prefix(while: { $0 == " "}).count == 2 })
            
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
                        let installedVersionInfo = installedPodsFromLock.first(where: { $0.contains(" \(name) ") }),
                        let installedVersion = installedVersionInfo
                            .findMatches(forRegex: "\\((.*?)\\)")
                            .first?.dropFirst().dropLast() {
                        
                        // If this Pod is declared with a version. e.g - pod 'RxSwift', '~> 4.1.1',
                        // replace the verion info with a format supported by this app.
                        if let versionInfo = components.fourth,  versionInfo.isUnsupportedPodVersionInfo {
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
    
    func runCommand(_ command: Command) -> Observable<String> {
        return Observable.create { observer -> Disposable in
            let disposable = BooleanDisposable()
            
            let result = command.run { observer.onNext($0) }
            
            switch result {
            case .success:
                observer.onNext("Done.")
                observer.onCompleted()
            case .error(let error):
                observer.onError(error)
            }
            return disposable
        }
    }

}

