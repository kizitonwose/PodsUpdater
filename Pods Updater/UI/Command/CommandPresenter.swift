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
    }
    
    func run(command: Command) {
        source.runCommand(command)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] line in
                self?.view?.showOutput(line)
            }, onCompleted: { [weak self] in
                self?.view?.showCommandFinished()
            }).disposed(by: disposeBag)
    }
}
