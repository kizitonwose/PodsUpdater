//
//  NSStoryboardExtensions.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

extension NSStoryboard {
    func instantiateCommandViewController(with command: Command,
                                          successHandler: ((CommandViewController) -> Void)? = nil) -> CommandViewController {
        let vc = instantiateController(withIdentifier: .commandViewController) as! CommandViewController
        vc.command = command
        vc.successHandler = successHandler
        return vc
    }
    
    func instantiatePodfileFixViewController(with result: PodFileCleanResult) -> PodfileFixViewController {
        let vc = instantiateController(withIdentifier: .podfileFixViewController) as! PodfileFixViewController
        vc.result = result
        return vc
    }
}

extension NSStoryboard.SceneIdentifier {
    public static let podfileFixViewController = "PodfileFixViewController"
    public static let commandViewController = "CommandViewController"
}

extension NSStoryboard.Name {
    public static let main = "Main"
}
