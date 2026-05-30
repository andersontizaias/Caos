import Foundation
#if canImport(UIKit)
import UIKit
public typealias CaosColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias CaosColor = NSColor
#endif

public struct CaosProps {
    let data: [String: Any]

    public init(_ data: [String: Any] = [:]) { self.data = data }

    public func string(_ key: String) -> String? { data[key] as? String }
    public func int(_ key: String) -> Int? { data[key] as? Int }
    public func double(_ key: String) -> Double {
        if let d = data[key] as? Double { return d }
        if let i = data[key] as? Int { return Double(i) }
        if let s = data[key] as? String, let d = Double(s) { return d }
        return 0.0
    }
    public func bool(_ key: String) -> Bool? {
        if let b = data[key] as? Bool { return b }
        if let s = data[key] as? String { return s == "true" }
        return nil
    }
    public func nested(_ key: String) -> CaosProps? {
        guard let dict = data[key] as? [String: Any] else { return nil }
        return CaosProps(dict)
    }
    public func array(_ key: String) -> [CaosProps]? {
        guard let arr = data[key] as? [[String: Any]] else { return nil }
        return arr.map { CaosProps($0) }
    }

    /// Parses a hex color string (#RGB, #RRGGBB, #AARRGGBB) into a platform color.
    public func color(_ key: String) -> CaosColor? {
        guard let hex = data[key] as? String else { return nil }
        var cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        switch cleaned.count {
        case 3:
            cleaned = cleaned.map { "\($0)\($0)" }.joined()
        case 6:
            break
        case 8:
            break
        default:
            return nil
        }
        guard cleaned.count == 6 || cleaned.count == 8,
              let value = UInt64(cleaned, radix: 16) else { return nil }
        let a, r, g, b: CGFloat
        if cleaned.count == 8 {
            a = CGFloat((value >> 24) & 0xFF) / 255
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >>  8) & 0xFF) / 255
            b = CGFloat( value        & 0xFF) / 255
        } else {
            a = 1.0
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >>  8) & 0xFF) / 255
            b = CGFloat( value        & 0xFF) / 255
        }
        return CaosColor(red: r, green: g, blue: b, alpha: a)
    }
}
