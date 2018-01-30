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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        tableView.reloadData()
    }
    
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

