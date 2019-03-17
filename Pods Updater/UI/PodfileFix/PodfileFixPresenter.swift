//
//  PodfileFixPresenter.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class PodfileFixPresenter: PodfileFixContract.Presenter {
    
    private weak var view : PodfileFixContract.View?
    private var disposeBag = DisposeBag()
    private var source: DataSource
    var result: PodFileCleanResult
    
    init(view: PodfileFixContract.View, source: DataSource, result: PodFileCleanResult) {
        self.source = source
        self.view = view
        self.result = result
    }
    
    func updatePodFileWitNewData() {
        source.writePodfileData(result.newContent, toPodfile: result.url)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.view?.showPodfileSaveSuccess()
                }, onError: { [weak self] _ in
                    self?.view?.showPodfileSaveError()
            }).disposed(by: disposeBag)
    }
    
}
