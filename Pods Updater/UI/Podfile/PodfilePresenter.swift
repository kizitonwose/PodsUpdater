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
    private var source: DataSource!
    var podFileUrl: URL
    var pendingReplacement: String

    init(view: PodfileContract.View, source: DataSource, podFileUrl: URL, pendingReplacement: String) {
        self.source = source
        self.view = view
        self.podFileUrl = podFileUrl
        self.pendingReplacement = pendingReplacement
    }
    
    func updatePodFileWitNewData() {
  
    }
    
    
    func start() { }
    
    func stop() {  }
}
