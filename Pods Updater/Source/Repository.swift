//
//  Repository.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Foundation
import RxSwift

class Repository: DataSource {

    public static let instance = Repository()

    private init() { }
    
    func parsePodfile(at path: URL) -> Single<[Pod]> {
        let content = try! String(contentsOf: path, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        let pods = [Pod]()
        for (index, line) in lines.enumerated() {
            print("\(index). \(line)")
            let components = line.components(separatedBy: "'")
            for (index, line) in components.enumerated() {
                print("\(line)")
            }
        }
        return Single.just([])
    }

}

enum ProcessResult {
    case success(output: String?)
    case error(output: String?)
}
