//
//  PodfileFixContract.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct PodfileFixContract {
    typealias View = _PodfileFixView
    typealias Presenter = _PodfileFixPresenter
}

protocol _PodfileFixView: BaseContract.View {
    func showPodfileSaveSuccess()
    func showPodfileSaveError()
}

protocol _PodfileFixPresenter: BaseContract.Presenter {
    func updatePodFileWitNewData()
}
