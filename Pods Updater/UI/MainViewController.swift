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
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var selectPodfileButton: NSButton!
    @IBOutlet weak var tableView: PodsTableView!
    private var presenter: MainContract.Presenter!
    let disposeBag = DisposeBag()
    
    let openPanel: NSOpenPanel = {
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
        presenter = MainPresenter(view: self, source: Repository.instance)
        
        setupViews()
        tableView.reloadData()
    }
}

extension MainViewController: MainContract.View {
    
    func showPodfileReadPercentage(_ progress: Double) {
        progressIndicator.doubleValue = progress
    }
    
    func showPodsInformation(with pods: [Pod]) {
        tableView.pods = pods
    }
    
}

extension MainViewController {
    
    fileprivate func setupViews() {
        setupButton()
        setupTableView()
    }
    
    fileprivate func setupButton() {
        selectPodfileButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                if (self.openPanel.runModal() == .OK) {
                    self.presenter.parsePodfile(at: self.openPanel.url!)
                } else {
                    // User clicked on "Cancel"
                    print("User cancelled")
                    return
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
    }
}

