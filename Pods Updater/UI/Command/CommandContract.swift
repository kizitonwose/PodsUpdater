//
//  CommandContract.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 02/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct CommandContract {
    typealias View = _CommandView
    typealias Presenter = _CommandPresenter
}

protocol _CommandView: BaseContract.View {
    func showOutput(_ output: String)
    func onCommandSuccess()
}

protocol _CommandPresenter: BaseContract.Presenter {
    func run(command: Command)
}
