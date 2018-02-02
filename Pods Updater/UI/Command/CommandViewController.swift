//
//  CommandViewController.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 02/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class CommandViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    @IBOutlet var closeButton: NSButton!
    let disposeBag = DisposeBag()
    var command = Command.updateRepo
    fileprivate var presenter: CommandContract.Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter = CommandPresenter(view: self, source: Repository.instance, command: command)
        presenter.run(command: command)
    }
}

extension CommandViewController: CommandContract.View {
    func showOutput(_ output: String) {
        textView.string = textView.string.appending(output)
        textView.scrollToEndOfDocument(nil)
    }
}

extension CommandViewController {
    func setupViews() {
        setupTextView()
        setupButton()
    }
    
    func setupTextView() {
        textView.backgroundColor = NSColor(hex: "#263238")
        textView.textColor = .white
        textView.font = NSFont.systemFont(ofSize: 14)
    }
    
    func setupButton() {
        closeButton.title = "Close"
        closeButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.view.window?.close()
            }).disposed(by: disposeBag)
    }    
}
