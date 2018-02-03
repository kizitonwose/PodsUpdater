//
//  MainViewController
//  Pods Updater
//
//  Created by Kizito Nwose on 29/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var selectPodfileButton: NSPopUpButton!
    @IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var installPodButton: NSButton!
    @IBOutlet weak var filterButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var tableView: PodsTableView!
    private var presenter: MainContract.Presenter!
    private let disposeBag = DisposeBag()
    private let openPanel: NSOpenPanel = {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Podfile"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = false
        return openPanel
    }()
    private let infoAlert: NSAlert = {
        let alert = NSAlert()
        alert.messageText = "Important"
        alert.informativeText = "This app searches your local pod spec repository to get pod versions. For best results, it's important that this repo is up to date. This can be achieved by running the \"pod repo update\" command."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Close")
        alert.addButton(withTitle: "Run update command now")
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self, source: Repository.instance)
        
        setupViews()
        tableView.reloadData()
    }
    
}

// MARK:- MainContract.View
extension MainViewController: MainContract.View {
    func showPodWithInvalidFormatWarning() {
        let alert = NSAlert()
        alert.messageText = "Important"
        alert.informativeText = "One or more Pods in your Podfile is declared with a format that is not supported by this app. The app can analyze your Podfile and show which lines should be fixed."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Analize now")
        alert.addButton(withTitle: "Close")
        alert.beginSheetModal(for: view.window!) { [unowned self] response in
            if response == .alertFirstButtonReturn {
                self.presenter.cleanUpPodfileAtCurrentUrl()
            }
        }
    }
    
    func showPodfileParseError() {
       showErrorAlert(content: "Could not parse the selected file.")
    }
    
    func showPodfileReadPercentage(_ progress: Double) {
        progressIndicator.doubleValue = progress
    }
    
    func showPodsInformation(with pods: [Pod]) {
        tableView.pods = pods
        if pods.isEmpty {
            installPodButton.isHidden = true
        }
    }
    
    func showProjectName(_ name: String) {
        projectNameTextField.stringValue = name
    }
    
    func setProgress(enabled: Bool) {
        filterButton.isEnabled = !enabled
        selectPodfileButton.isEnabled = !enabled
        installPodButton.isEnabled = !enabled
        tableView.isEnabled = !enabled
    }
    
    func showLocalPodsUpdateInformation() {
        infoAlert.beginSheetModal(for: view.window!) { [unowned self] response in
            if response == .alertSecondButtonReturn {
                self.runComman(.updateRepo)
            }
        }
    }
    
    func showPodCleanUpResult(_ result: PodFileCleanResult) {
        let podfileVC = storyboard?.instantiateController(withIdentifier: .podfileViewController)  as! PodfileViewController
        podfileVC.result = result
        presentViewControllerAsModalWindow(podfileVC)
    }
    
    func showPodCleanUpError(_ reason: String?) {
        showErrorAlert(content: reason ?? "Could not complete operation.")
    }
    
    private func showErrorAlert(content: String) {
        let alert = NSAlert()
        alert.messageText = "An error occured"
        alert.informativeText = content
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Close")
        alert.beginSheetModal(for: view.window!)
    }
    
    fileprivate func runComman(_ command: Command) {
        let vc = self.storyboard?.instantiateController(withIdentifier: .commandViewController)
            as! CommandViewController
        vc.command = command
        self.presentViewControllerAsModalWindow(vc)
    }
}

// MARK:- Setup
extension MainViewController {
    
    fileprivate func setupViews() {
        setupButtons()
        setupTableView()
    }
    
    fileprivate func setupButtons() {
        // Podfile selection button
        selectPodfileButton.removeAllItems()
        selectPodfileButton.addItems(withTitles: ["Select Podfile", "Find Versions", "Make Compatible"])
        selectPodfileButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                if (self.openPanel.runModal() == .OK) {
                    switch self.selectPodfileButton.indexOfSelectedItem {
                    case 1: // Analyze Podfile
                        self.presenter.findVersionsForPodfile(at: self.openPanel.url!,
                                                              onlyNew: self.filterButton.state == .on)
                    case 2: // Sanitize Podfile
                        self.presenter.cleanUpPodfile(at: self.openPanel.url!)
                    default: break
                    }
                }
            }).disposed(by: disposeBag)
        
        // Pod installation button
        installPodButton.isHidden = true // Hide the button initially
        installPodButton.title = "Install Pod(s)"
        installPodButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.runComman(.install(podFileUrl: self.openPanel.url!.deletingLastPathComponent()))
            }).disposed(by: disposeBag)
        
        
        // Help buttton
        helpButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                let alert = NSAlert()
                alert.messageText = "About Pods Updater"
                alert.informativeText = "This app helps you find updates for frameworks in your Podfile by searching your local spec repository. \n\nThe app requires that your Podfile follows a specific pattern when declaring Pods: \npod 'PodName', 'ExactVersion' \nexample: pod 'RxSwift', '4.1.1' \n\nIf your Podfile already follows this pattern, proceed with searching for versions of Pods in your Podfile using the \"Find Versions\" option. Otherwise, use the \"Make Compatible\" option to fix your Podfile first!"
                alert.addButton(withTitle: "Close")
                alert.beginSheetModal(for: self.view.window!)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func setupTableView() {
        for (index, column) in tableView.tableColumns.enumerated() {
            column.headerCell.alignment = .center
            switch index {
            case 0: column.title = "Pod Name"
            case 1: column.title = "Current Version"
            case 2: column.title = "Available Versions"
            case 3: column.title = "Get Version"
            default: preconditionFailure("Unknows column index")
            }
        }
        
        tableView.buttonClickHandler = { [unowned self] pod, newVersion in
            self.presenter.setVersion(newVersion, forPod: pod)
            self.installPodButton.isHidden = false // The user can install command on this Podfile
        }
    }
}

