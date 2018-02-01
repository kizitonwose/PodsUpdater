//
//  PodfileViewController.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa
import Highlightr

class PodfileViewController: NSViewController {

    @IBOutlet weak var oldPodfileLabel: NSTextField!
    @IBOutlet weak var newPodfileLabel: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!

    lazy var highlighter: Highlightr? = {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "paraiso-dark")
        return highlightr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}

//MARK: Setup
extension PodfileViewController {
    
    func setupView() {
        if let highlighter = highlighter {
            [oldPodfileLabel, newPodfileLabel].forEach {
                $0?.backgroundColor = highlighter.theme.themeBackgroundColor
                $0?.font = highlighter.theme.codeFont
            }
        }
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: "#263238").cgColor
    }
}
