//
//  CommandPresenter.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 02/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class CommandPresenter: CommandContract.Presenter {
    
    private weak var view : CommandContract.View?
    private var disposeBag = DisposeBag()
    private var source: DataSource
    var command: Command
    
    init(view: CommandContract.View, source: DataSource, command: Command) {
        self.source = source
        self.view = view
        self.command = command
        run(command: command)
    }
    
    func run(command: Command) {
        source.runCommand(command)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.view?.showOutput($0)
                }, onError: { [weak self] in
                    // Print errors to the command output
                    self?.view?.showOutput($0.localizedDescription)
                }, onCompleted: { [weak self] in
                    if case .updateRepo = command {
                        UserDefaults.standard.set(Date(), forKey: .lastRepoUpdate)
                    }
                    self?.view?.onCommandSuccess()
            }).disposed(by: disposeBag)
    }
}
