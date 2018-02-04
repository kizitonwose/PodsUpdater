//
//  AppDelegate.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 29/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag.not() {
            sender.windows.first { $0 is MainWindow }?.makeKeyAndOrderFront(self)
        }
        return true
    }
    
}

