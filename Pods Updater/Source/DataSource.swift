//
//  DataSource.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

protocol DataSource {
    func findVersionsForPodfile(at url: URL) -> Observable<ProgressResult<PodfileVersionCheckResult>>
    func getProjectNameForPodfile(at url: URL) -> String
    func setVersion(_ version: String, forPod pod: Pod, inPodfile url: URL)
    func cleanUpPodfile(at url: URL) -> Single<PodFileCleanResult>
    func writePodfileData(_ data: String, toPodfile url: URL) -> Completable
    func runCommand(_ command: Command) -> Observable<String>
}
