//
//  HomeViewController
//  Pods Updater
//
//  Created by Kizito Nwose on 29/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class HomeViewController: NSViewController {
    
    @IBOutlet weak var projectNameTextField: NSTextField!
    @IBOutlet weak var selectPodfileButton: NSPopUpButton!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var helpButton: NSButton!
    @IBOutlet weak var installPodButton: NSButton!
    @IBOutlet weak var filterButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var tableView: PodsTableView!
    private var presenter: HomeContract.Presenter!
    private let disposeBag = DisposeBag()
    private let podfileSelectionPanel: NSOpenPanel = {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Podfile"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = false
        return openPanel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HomePresenter(view: self, source: Repository.instance)
        
        setupViews()
        tableView.reloadData()
    }
    
}

// MARK:- HomeContract.View
extension HomeViewController: HomeContract.View {
    func showPodVersionsSearchCompletion() {
        let notification = NSUserNotification()
        notification.title = "Search completed"
        notification.informativeText = projectNameTextField.stringValue
        notification.deliveryDate = Date()
   
        // Note: Notification is not delivered when the app
        // is in front. This is the intended behaviour.
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func showPodWithInvalidFormatWarning() {
        let alert = NSAlert()
        alert.messageText = "Important"
        alert.informativeText = "One or more Pods in your Podfile is declared with a format that is not supported by this app. " +
        "The app can analyze your Podfile and show which lines should be fixed."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Analyze now")
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
        refreshButton.isEnabled = !enabled
        refreshButton.isHidden = enabled
        installPodButton.isEnabled = !enabled
        tableView.isEnabled = !enabled
    }
    
    func showNoUpdatesMessage() {
        let alert = NSAlert()
        alert.messageText = "Search completed"
        alert.informativeText = "No updates found."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Close")
        alert.beginSheetModal(for: view.window!)
    }
    
    func showLocalPodsUpdateInformation(resultCount: Int) {
        let alert = NSAlert()
        alert.messageText = "Search completed"
        let emptyResultText = "\(resultCount == 0 ? "No results found.\n\n" : "")"
        alert.informativeText = "\(emptyResultText)Note: This app searches your local pod spec repository to get pod versions. " +
        "For best results, it's important that your local repo is up to date. This can be achieved by running \"pod repo update\" command."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Close")
        alert.addButton(withTitle: "Run update command")
        
        alert.beginSheetModal(for: view.window!) { [unowned self] response in
            if response == .alertSecondButtonReturn {
                self.runCommand(.updateRepo) { [unowned self] vc in
                    // Dismiss command output and search again after the local repo is updated.
                    vc.presentingViewController?.dismiss(vc)
                    self.presenter.findVersionsForPodfile(at: self.podfileSelectionPanel.url!,
                                                          onlyNew: self.filterButton.isOn)
                }
            }
        }
    }
    
    func showPodCleanUpResult(_ result: PodFileCleanResult) {
        let podfileVC = storyboard!.instantiatePodfileFixViewController(with: result)
        presentAsModalWindow(podfileVC)
    }
    
    func showPodCleanUpError(_ reason: String?) {
        showErrorAlert(content: reason ?? "Could not complete operation.")
    }
    
    private func showErrorAlert(content: String) {
        let alert = NSAlert()
        alert.messageText = "An error occurred"
        alert.informativeText = content
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Close")
        alert.beginSheetModal(for: view.window!)
    }
    
    fileprivate func runCommand(_ command: Command, successHandler: ((CommandViewController) -> Void)? = nil) {
        let vc = self.storyboard!.instantiateCommandViewController(with: command, successHandler: successHandler)
        self.presentAsModalWindow(vc)
    }
}

// MARK:- Setup
extension HomeViewController {
    
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
                if (self.podfileSelectionPanel.runModal() == .OK) {
                    switch self.selectPodfileButton.indexOfSelectedItem {
                    case 1: // Analyze Podfile
                        self.presenter.findVersionsForPodfile(at: self.podfileSelectionPanel.url!,
                                                              onlyNew: self.filterButton.isOn)
                    case 2: // Sanitize Podfile
                        self.presenter.cleanUpPodfile(at: self.podfileSelectionPanel.url!)
                    default: break
                    }
                }
            }).disposed(by: disposeBag)
        
        // Refresh Button
        refreshButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                if let url = self.podfileSelectionPanel.url {
                    self.presenter.findVersionsForPodfile(at: url,
                                                          onlyNew: self.filterButton.isOn)
                }
            }).disposed(by: disposeBag)
                
        // Pod installation button
        installPodButton.isHidden = true // Hide the button initially
        installPodButton.title = "Install Pod(s)"
        installPodButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.runCommand(.install(podFileUrl: self.podfileSelectionPanel.url!.deletingLastPathComponent()))
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
        
        // Filter Button
        filterButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.presenter.filterPod(onlyNew: self.filterButton.isOn)
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
        
        tableView.useVersionClickHandler = { [unowned self] pod, newVersion in
            self.presenter.setVersion(newVersion, forPod: pod)
            self.installPodButton.isHidden = false // The user can install command on this Podfile
        }
    }
}

