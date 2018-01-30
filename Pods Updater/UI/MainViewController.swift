//
//  MainViewController
//  Pods Updater
//
//  Created by Kizito Nwose on 29/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var tableView: PodsTableView!
    private var presenter: MainContract.Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self, source: Repository.instance)
        
        setup()
        tableView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidDisappear()
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Podfile"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = false
        //        openPanel.allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]
        
        if (openPanel.runModal() == NSApplication.ModalResponse.OK) {
            presenter.parsePodfile(at: openPanel.url!)
        } else {
            // User clicked on "Cancel"
            print("User cancelled")
            return
        }
        
    }
    
}

extension MainViewController: MainContract.View {
    
}

extension MainViewController {
    fileprivate func setup() {
        for (index, column) in tableView.tableColumns.enumerated() {
            column.headerCell.alignment = .center
            switch index {
            case 0: column.title = "Pod Name"
            case 1: column.title = "Current Version"
            case 2: column.title = "Available versions"
            case 3: column.title = "Use version"
            default: preconditionFailure("Unknows column index")
            }
        }
    }
}

