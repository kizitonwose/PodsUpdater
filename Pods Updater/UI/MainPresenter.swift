//
//  MainPresenter.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class MainPresenter: MainContract.Presenter {
    
    private weak var view : MainContract.View?
    private var disposeBag = DisposeBag()
    private var source: DataSource!
    var currentPath: URL? = nil
    
    init(view: MainContract.View, source: DataSource) {
        self.source = source
        self.view = view
    }
    
    func parsePodfile(at path: URL) {
        currentPath = path
        source.parsePodfile(at: path)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] progressResult in
                //print("Finished with pods: \(pods)")
                if progressResult.result == nil {
                    self?.view?.showPodfileReadPercentage(progressResult.progress)
                } else {
                    self?.view?.showPodsInformation(with: progressResult.result!)
                }
                }, onError: { error in
                    print("Finished with error: \(error)")
            }).disposed(by: disposeBag)
    }

    func start() { }
    
    func stop() {  }
}
