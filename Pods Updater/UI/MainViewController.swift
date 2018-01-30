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

        tableView.reloadData()
      
    }
    
}
