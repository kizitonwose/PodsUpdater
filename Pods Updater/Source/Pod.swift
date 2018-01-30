//
//  Pod.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

struct Pod {
    var name = ""
    var lineNumber = -1
    var currentVersion = ""
    var availableVersions = [String]()
    
    init(name: String, lineNumber: Int, currentVersion: String) {
        self.name = name
        self.lineNumber = lineNumber
        self.currentVersion = currentVersion
    }
    
    init() {
        
    }
}
