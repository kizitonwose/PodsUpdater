//
//  CommandViewController.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 02/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

class CommandViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
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
        textView.string = textView.string + output
    }
    
    func showCommandFinished() {
        print("close")
        view.window?.close()
    }
}

extension CommandViewController {
    func setupViews() {
        textView.backgroundColor = NSColor(hex: "#263238")
        textView.textColor = .white
    }
}
