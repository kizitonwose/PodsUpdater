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
    private var source: DataSource
    var currentUrl: URL? = nil
    
    init(view: MainContract.View, source: DataSource) {
        self.source = source
        self.view = view
    }
    
    func findVersionsForPodfile(at url: URL, onlyNew: Bool) {
        currentUrl = url
        view?.setProgress(enabled: true)
        showPodfileMetaData(forPodfile: url)
        
        source.findVersionsForPodfile(at: url, onlyNew: onlyNew)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .do(onCompleted: { [weak self] in
                self?.view?.setProgress(enabled: false)
            })
            .subscribe(onNext: { [weak self] progressResult in
                if progressResult.result == nil {
                    self?.view?.showPodfileReadPercentage(progressResult.progress)
                } else {
                    let result = progressResult.result!
                    self?.view?.showPodsInformation(with: result.pods)
                    if result.hasPodWithUnsupportedFormat {
                        self?.view?.showPodWithInvalidFormatWarning()
                    } else {
                        self?.view?.showLocalPodsUpdateInformation()
                    }
                }
                }, onError: { [weak self] error in
                    self?.view?.showPodfileParseError()
            }).disposed(by: disposeBag)
    }
    
    func setVersion(_ version: String, forPod pod: Pod) {
        if let currentUrl = currentUrl {
            source.setVersion(version, forPod: pod, inPodfile: currentUrl)
        }
    }
    
    func cleanUpPodfile(at url: URL) {
        showPodfileMetaData(forPodfile: url)
        source.cleanUpPodfile(at: url)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] result in
                self?.view?.showPodCleanUpResult(result)
            }, onError: { [weak self] error in
                self?.view?.showPodCleanUpError((error as? AppError)?.reason ?? nil)
            }).disposed(by: disposeBag)
    }
    
    func cleanUpPodfileAtCurrentUrl() {
        if let currentUrl = currentUrl {
            cleanUpPodfile(at: currentUrl)
        }
    }
    
    private func showPodfileMetaData(forPodfile url: URL) {
        let projectName = source.getProjectNameForPodfile(at: url)
        view?.showProjectName(projectName)
        view?.showPodsInformation(with: [])
    }

}
