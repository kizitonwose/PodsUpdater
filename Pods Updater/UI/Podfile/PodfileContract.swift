//
//  PodfileContract.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct PodfileContract {
    typealias View = _PodfileView
    typealias Presenter = _PodfilePresenter
}

protocol _PodfileView: BaseContract.View {
    func showPodfileSaveSuccess()
    func showPodfileSaveError()
}

protocol _PodfilePresenter: BaseContract.Presenter {
    func updatePodFileWitNewData()
}
