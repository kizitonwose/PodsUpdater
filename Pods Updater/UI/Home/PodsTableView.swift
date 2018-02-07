//
//  PodsTableView.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

class PodsTableView: NSTableView {
    
    var buttonClickHandler: ((Pod, _ newVersion: String) -> ())?
    
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
        registerCellNib(PodNewVersionsTableCellView.self, forIdentifier: .newVersionsCell)
        registerCellNib(PodUseVersionCellView.self, forIdentifier: .useVersionCell)
    }
}

// MARK:- NSTableViewDelegate
extension PodsTableView: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let pod = pods[row]
        if tableColumn == tableView.tableColumns.first {
            let cell = tableView.makeView(withIdentifier: .podNameCell, owner: nil)  as! NSTableCellView
            cell.textField?.stringValue = pod.name
            cell.textField?.alignment = .center
            return cell
        }
        
        if tableColumn == tableView.tableColumns.second {
            let cell = tableView.makeView(withIdentifier: .currentVersionCell, owner: nil)  as! NSTableCellView
            cell.textField?.stringValue = pod.currentVersion
            cell.textField?.alignment = .center
            return cell
        }
        
        if tableColumn == tableView.tableColumns.third {
            let cell = tableView.makeView(withIdentifier: .newVersionsCell, owner: nil)  as! PodNewVersionsTableCellView
            cell.versionsPopUp.removeAllItems()
            cell.versionsPopUp.addItems(withTitles: pod.availableVersions)
            return cell
        }
        
        if tableColumn == tableView.tableColumns.fourth {
            let cell = tableView.makeView(withIdentifier: .useVersionCell, owner: nil)  as! PodUseVersionCellView
            cell.useVersionButton.title = "Get"
            cell.buttonClickHandler = { [unowned self] in
                let row = self.row(for: cell)

                print("Selected row: \(row)")
                if let newVersionView = self.view(atColumn: 2, row: row, makeIfNecessary: true)
                    as? PodNewVersionsTableCellView, let newVersion = newVersionView.versionsPopUp.selectedItem?.title {
                   
                    self.buttonClickHandler?(self.pods[row], newVersion)
                    self.removeRows(at: IndexSet(integer: row), withAnimation: [.effectFade, .slideRight])
                    self.pods.remove(at: row)
                }
            }
            return cell
        }
        return nil
    }
}

// MARK:- NSTableViewDataSource
extension PodsTableView: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return pods.count
    }
}

// MARK:- PodNewVersionsTableCellView
class PodNewVersionsTableCellView: NSTableCellView {
    
    @IBOutlet weak var versionsPopUp: NSPopUpButton!
    
}

// MARK:- PodUseVersionCellView
class PodUseVersionCellView: NSTableCellView {
    
    @IBOutlet weak var useVersionButton: NSButton!
    var buttonClickHandler: (() -> ())?
    
    @IBAction func buttonClicked(_ sender: Any) {
        buttonClickHandler?()
    }
}

// MARK:- NSUserInterfaceItemIdentifier
extension NSUserInterfaceItemIdentifier {
    public static let podNameCell = NSUserInterfaceItemIdentifier("podNameCell")
    public static let currentVersionCell = NSUserInterfaceItemIdentifier("currentVersionCell")
    public static let newVersionsCell = NSUserInterfaceItemIdentifier("newVersionsCell")
    public static let useVersionCell = NSUserInterfaceItemIdentifier("useVersionCell")
}

