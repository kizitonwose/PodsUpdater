//
//  HomePresenter.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class HomePresenter: HomeContract.Presenter {
    
    private weak var view : HomeContract.View?
    private var disposeBag = DisposeBag()
    private var source: DataSource
    private var pods: [Pod] = [Pod]()
    var currentUrl: URL? = nil
    private var lastRepoUpdateDate: Date?
    
    init(view: HomeContract.View, source: DataSource) {
        self.source = source
        self.view = view
    }
    
    func findVersionsForPodfile(at url: URL, onlyNew: Bool) {
        currentUrl = url
        view?.setProgress(enabled: true)
        showPodfileMetaData(forPodfile: url)
        
        source.findVersionsForPodfile(at: url)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] progressResult in
                guard let view = self?.view else { return }

                
                if progressResult.result == nil {
                    view.showPodfileReadPercentage(progressResult.progress)
                } else {
                    view.setProgress(enabled: false)
                    
                    let result = progressResult.result!
                    self?.pods = result.pods
                    self?.filterPod(onlyNew: onlyNew)
                    if result.hasPodWithUnsupportedFormat {
                        view.showPodWithInvalidFormatWarning()
                    } else {
                        guard let lastRepoUpdateDate = self?.lastRepoUpdateDate else {
                            // Repo has not been update since app launch
                            view.showLocalPodsUpdateInformation(resultCount: result.pods.count)
                            return
                        }
                        
                        if let lastRepoUpdateMinute = Calendar.current.dateComponents([.minute], from: lastRepoUpdateDate, to: Date()).minute {
                            if lastRepoUpdateMinute > 60 * 4 {
                                // It's been more than 4 hours since last repo update, show message again.
                                view.showLocalPodsUpdateInformation(resultCount: result.pods.count)
                            } else if result.pods.isEmpty {
                                view.showNoUpdatesMessage()
                            }
                        }
                    }
                }
                }, onError: { [weak self] error in
                    self?.view?.setProgress(enabled: false)
                    self?.view?.showPodfileParseError()
            }).disposed(by: disposeBag)
    }
    
    func filterPod(onlyNew: Bool) {
        if onlyNew {
            var newPods = [Pod]()
            for pod in pods {
                var newPod = pod
                var versions = newPod.allVersions
                let index = newPod.lineIndex
                if let currentVersionIndex = versions.index(of: pod.currentVersion) {
                    versions = Array(versions.dropLast(versions.count - currentVersionIndex))
                }
                newPod.availableVersions = versions
                if newPod.availableVersions.isNotEmpty {
                    if newPods.contains(newPod) {
                        newPods[newPods.index(of: newPod)!].otherLineIndices.append(index)
                    } else {
                        newPods.append(newPod)
                    }
                }
            }
            self.view?.showPodsInformation(with: newPods)
        } else {
            self.view?.showPodsInformation(with: pods)
        }
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

    func repoUpdated(at date: Date) {
        lastRepoUpdateDate = date
    }
}
