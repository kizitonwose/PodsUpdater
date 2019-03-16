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
    var command: Command = .updateRepo
    var successHandler: ((CommandViewController) -> Void)?
    fileprivate var presenter: CommandContract.Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter = CommandPresenter(view: self, source: Repository.instance, command: command)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Command output"
        view.window?.titlebarAppearsTransparent = true
    }
}

extension CommandViewController: CommandContract.View {
    func showOutput(_ output: String) {
        textView.string = textView.string.appending(output)
        textView.scrollToEndOfDocument(nil)
    }
    
    func onCommandSuccess() {
        successHandler?(self)
    }
}

extension CommandViewController {
    func setupViews() {
        setupTextView()
    }
    
    func setupTextView() {
        let color = NSColor(hex: "#263238")
        view.wantsLayer = true
        view.layer?.backgroundColor = color.cgColor
        textView.backgroundColor = color
        textView.textColor = .white
        textView.font = NSFont.systemFont(ofSize: 14)
    }
}
