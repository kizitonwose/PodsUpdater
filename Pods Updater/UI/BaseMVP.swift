//
//  BaseMVP.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct BaseContract {
    typealias View = _BaseView
    typealias Presenter = _BasePresenter
}

protocol _BaseView : class {
    
}

protocol _BasePresenter : class {
    func start()
    
    func stop()
}

extension _BasePresenter {    
    func start() { }
    
    func stop() {  }
}
