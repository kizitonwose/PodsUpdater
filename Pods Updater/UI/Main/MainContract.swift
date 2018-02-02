//
//  MainContract.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct MainContract {
    typealias View = _MainView
    typealias Presenter = _MainPresenter
}

protocol _MainView: BaseContract.View {
    func showPodfileParseError()
    func showPodsInformation(with pods: [Pod])
    func showPodfileReadPercentage(_ progress: Double)
    func showProjectName(_ name: String)
    func setProgress(enabled: Bool)
    func showPodWithInvalidFormatWarning()
    func showLocalPodsUpdateInformation()
    func showPodCleanUpResult(_ result: PodFileCleanResult)
    func showPodCleanUpError(_ reason: String?)
}

protocol _MainPresenter: BaseContract.Presenter {
    func findVersionsForPodfile(at url: URL, onlyNew: Bool)
    func setVersion(_ version: String, forPod pod: Pod)
    func cleanUpPodfile(at url: URL)
    func cleanUpPodfileAtCurrentUrl()
}
