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
    }
}

extension PodsTableView: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
}

extension PodsTableView: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return pods.count
    }
}
