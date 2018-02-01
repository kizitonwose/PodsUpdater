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
    
    func showPodfileReadPercentage(_ progress: Double) {
        progressIndicator.doubleValue = progress
    }
    
    func showPodsInformation(with pods: [Pod]) {
        tableView.pods = pods
    }
    
    func showProjectName(_ name: String) {
        projectNameTextField.stringValue = name
    }
    
    func setProgress(enabled: Bool) {
        filterButton.isEnabled = !enabled
        selectPodfileButton.isEnabled = !enabled
        tableView.isEnabled = !enabled
    }
    
    func showLocalPodsUpdateInformation() {
        infoAlert.beginSheetModal(for: view.window!) { response in
            print(response)
        }
    }
    
    func showPodCleanUpResult(_ result: PodFileCleanResult) {
        if let podfileVC = storyboard?.instantiateController(withIdentifier: .podfileViewController)  as? PodfileViewController {
            podfileVC.result = result
            presentViewControllerAsModalWindow(podfileVC)
        }
    }
}

// MARK:- Setup
extension MainViewController {
    
    fileprivate func setupViews() {
        setupButton()
        setupTableView()
    }
    
    fileprivate func setupButton() {
        selectPodfileButton.removeAllItems()
        selectPodfileButton.addItems(withTitles: ["Select Podfile", "Analyze Podfile", "Sanitize Podfile"])
        selectPodfileButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                if (self.openPanel.runModal() == .OK) {
                    switch self.selectPodfileButton.indexOfSelectedItem {
                    case 1: // Analyze Podfile
                        self.presenter.parsePodfile(at: self.openPanel.url!,
                                                    onlyNewVersions: self.filterButton.state == .on)
                    case 2: // Sanitize Podfile
                        self.presenter.cleanUpPodfile(at: self.openPanel.url!)
                    default: break
                    }
                }
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
        }
    }
}

