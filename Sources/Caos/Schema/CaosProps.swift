import Foundation

public struct CaosProps {
    let data: [String: Any]

    public init(_ data: [String: Any] = [:]) {
        self.data = data
    }

    public func string(_ key: String) -> String? {
        data[key] as? String
    }

    public func int(_ key: String) -> Int? {
        data[key] as? Int
    }

    public func double(_ key: String) -> Double {
        if let doubleValue = data[key] as? Double { return doubleValue }
        if let intValue = data[key] as? Int { return Double(intValue) }
        if let stringValue = data[key] as? String, let parsed = Double(stringValue) { return parsed }
        return 0.0
    }

    public func bool(_ key: String) -> Bool? {
        if let boolValue = data[key] as? Bool { return boolValue }
        if let stringValue = data[key] as? String { return stringValue == "true" }
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

    /// Valida se uma chave contém uma string de cor hex válida (#RGB, #RRGGBB, #AARRGGBB).
    /// A conversão para UIColor/NSColor/SwiftUI.Color é responsabilidade do app.
    public func hexColor(_ key: String) -> String? {
        guard let hex = data[key] as? String else { return nil }
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard [3, 6, 8].contains(cleaned.count),
              cleaned.allSatisfy(\.isHexDigit) else { return nil }
        return hex
    }
}
