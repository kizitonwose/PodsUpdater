//
//  PodsTableView.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

class PodsTableView: NSTableView {
    
    var pods = [Pod]() {
        didSet {
            reloadData()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        dataSource = self
        delegate = self
        registerCellNib(PodNewVersionsTableCellView.self, forIdentifier: CellIdentifier.newVersionsCell)
    }
}

extension PodsTableView: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == tableView.tableColumns[0] {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(CellIdentifier.podNameCell.rawValue), owner: nil)  as! NSTableCellView
            cell.textField?.stringValue = "Alamofire"
            return cell
        }
        
        if tableColumn == tableView.tableColumns[1]{
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(CellIdentifier.currentVersionCell.rawValue), owner: nil)  as! NSTableCellView
            cell.textField?.stringValue = "Alamofire"
            return cell
        }
        
        if tableColumn == tableView.tableColumns[2] {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(CellIdentifier.newVersionsCell.rawValue), owner: nil)  as! PodNewVersionsTableCellView
            cell.versionsPopUp.addItems(withTitles: ["1.1.0", "1.1.1", "1.1.2", "1.1.3"])
            return cell
        }
        return nil
    }
}

extension PodsTableView: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return 6
    }
}

extension PodsTableView {
    fileprivate enum CellIdentifier: String {
        case podNameCell = "podNameCell"
        case currentVersionCell = "currentVersionCell"
        case newVersionsCell = "newVersionsCell"
        case actionCell = "actionCell"
    }
}


class PodNewVersionsTableCellView: NSTableCellView {
    
    @IBOutlet weak var versionsPopUp: NSPopUpButton!
    
}
