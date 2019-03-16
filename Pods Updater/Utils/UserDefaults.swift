//
//  UserDefaults.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 03/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation

extension UserDefaults {
    public func value(forKey key: UserDefaultKey) -> Any? {
        return object(forKey: key.rawValue)
    }
    
    public func set(_ value: Any?, forKey key: UserDefaultKey) {
        set(value, forKey: key.rawValue)
    }
}

public enum UserDefaultKey: String {
    case highlightTheme
    case lastRepoUpdate
}
