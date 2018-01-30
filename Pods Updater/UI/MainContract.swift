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
    func showPodsInformation(with pods: [Pod])
    func showPodfileReadPercentage(_ progress: Double)
}

protocol _MainPresenter: BaseContract.Presenter {
    func parsePodfile(at path: URL)
}
