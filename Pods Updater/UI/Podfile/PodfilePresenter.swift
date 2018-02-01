//
//  PodfilePresenter.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class PodfilePresenter: PodfileContract.Presenter {
    
    private weak var view : PodfileContract.View?
    private var disposeBag = DisposeBag()
    private var source: DataSource
    var result: PodFileCleanResult

    init(view: PodfileContract.View, source: DataSource, result: PodFileCleanResult) {
        self.source = source
        self.view = view
        self.result = result
    }
    
    func updatePodFileWitNewData() {
  
    }
    
    
    func start() { }
    
    func stop() {  }
}
