//
//  Extensions.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 30/01/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa


// MARK: - NSTableView
extension NSTableView {
    func registerCellNib(_ cellClass: AnyClass, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        let nibName = String.className(cellClass)
        let nib = NSNib(nibNamed: nibName, bundle: nil)
        self.register(nib, forIdentifier: identifier)
    }
}

// MARK: String
extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}

extension String {
    func trimmingWhiteSpaces() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
    
    func splitByNewLines() -> [String] {
        return components(separatedBy: .newlines)
    }
    
    func splitByComma() -> [String] {
        return components(separatedBy: ",")
    }
}

extension String {
    var isValidPodLine: Bool {
        return self.starts(with: "pod")
    }
    
    var isUnsupportedPodVersionInfo: Bool {
        let trimmed = self.trimmingWhiteSpaces()
        if let firstCharecter = trimmed.first {
            return ["~","=",">","<"].contains(firstCharecter)
        }
        return false
    }
}

extension String {
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        if let range = range(of: string) {
            return replacingCharacters(in: range, with: replacement)
        }
        return String(self)
    }
    
    func findMatches(forRegex regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch {
            print("Regex error: \(error)")
            return []
        }
    }
}

extension String {
    func startIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}


// MARK:- Array
extension Array {
    var second: Element? {
        return self[safe: 1]
    }
    
    var third: Element? {
         return self[safe: 2]
    }
    
    var fourth: Element? {
         return self[safe: 3]
    }
}

extension Array where Element == String {
    func joinByNewLines() -> String {
        return self.joined(separator: "\n")
    }
}

// MARK:- Collection
extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK:- Bool
extension Bool {
    func not() -> Bool {
        return !self
    }
}

// MARK:- Character
extension Character {
    var isDigit: Bool {
        if let scalar = unicodeScalars.first {
            return CharacterSet.decimalDigits.contains(scalar)
        }
        return false
    }
}


//MARK: NSColor
extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


// MARK:- NSRect
extension NSRect {
    var center: CGPoint {
        return  CGPoint(x: NSMidX(self), y: NSMidY(self))
    }
}

// MARK:- NSRect
extension NSButton {
    var isOn: Bool {
        return state == .on
    }
}

