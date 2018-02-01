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

    @IBOutlet weak var oldPodfileTextView: NSTextView!
    @IBOutlet weak var newPodfileTextView: NSTextView!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    var result: PodFileCleanResult?
    var presenter: PodfileContract.Presenter!
    var hasSetup = false
    
    lazy var highlighter: Highlightr? = {
        let highlightr = Highlightr()
        highlightr?.setTheme(to: "paraiso-dark")
        return highlightr
    }()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if hasSetup.not() {
            setupView()
            presenter = PodfilePresenter(view: self, source: Repository.instance, result: result!)
            hasSetup = true
        }
    }
    
}

extension PodfileViewController: PodfileContract.View {
    
}

//MARK: Setup
extension PodfileViewController {
    
    func setupView() {
        [oldPodfileTextView, newPodfileTextView].forEach {
            if let highlighter = highlighter {
                $0?.backgroundColor = highlighter.theme.themeBackgroundColor
                $0?.font = highlighter.theme.codeFont
            }
            // Setting these values via Storyboard does not work due to a bug in NSTextView
            // https://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
            $0?.isAutomaticQuoteSubstitutionEnabled = false
            $0?.isAutomaticDashSubstitutionEnabled = false
            $0?.isAutomaticTextReplacementEnabled = false
        }
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hex: "#263238").cgColor
        
        oldPodfileTextView.isEditable = false
        let emptyString = NSAttributedString()
        oldPodfileTextView.textStorage?.append(highlighter?.highlight(result!.oldContent, as: "ruby") ?? emptyString)
        newPodfileTextView.textStorage?.append(highlighter?.highlight(result!.newContent, as: "ruby") ?? emptyString)
    }
}

