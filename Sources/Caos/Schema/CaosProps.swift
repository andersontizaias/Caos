//
//  CaosProps.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 29/05/26.
//

import UIKit
import SwiftUI

public struct CaosProps {
    private let data: [String: Any]

    public init(_ data: [String: Any] = [:]) { self.data = data }

    public func string(_ key: String) -> String? { data[key] as? String }
    public func int(_ key: String) -> Int? { data[key] as? Int }
    public func double(_ key: String) -> Double? {
        if let d = data[key] as? Double { return d }
        if let i = data[key] as? Int { return Double(i) }
        if let s = data[key] as? String { return Double(s) }
        return nil
    }
    public func bool(_ key: String) -> Bool? {
        if let b = data[key] as? Bool { return b }
        if let s = data[key] as? String { return s == "true" }
        return nil
    }
    public func color(_ key: String) -> UIColor? {
        guard let hex = data[key] as? String else { return nil }
        return UIColor(caosHex: hex)
    }
    @available(iOS 14.0, *)
    public func swiftUIColor(_ key: String) -> Color? {
        guard let c = color(key) else { return nil }
        return Color(uiColor: c)
    }
    public func nested(_ key: String) -> CaosProps? {
        guard let dict = data[key] as? [String: Any] else { return nil }
        return CaosProps(dict)
    }
    public func array(_ key: String) -> [CaosProps]? {
        guard let arr = data[key] as? [[String: Any]] else { return nil }
        return arr.map { CaosProps($0) }
    }
}

extension UIColor {
    convenience init?(caosHex: String) {
        let hex = caosHex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6 || hex.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }
        if hex.count == 6 {
            self.init(
                red:   CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8)  & 0xFF) / 255,
                blue:  CGFloat(value & 0xFF)         / 255,
                alpha: 1.0
            )
        } else {
            // 8-digit: AARRGGBB
            self.init(
                red:   CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8)  & 0xFF) / 255,
                blue:  CGFloat(value & 0xFF)         / 255,
                alpha: CGFloat((value >> 24) & 0xFF) / 255
            )
        }
    }
}
