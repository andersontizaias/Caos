import Foundation

public struct CaosProps {
    let data: [String: Any]

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
    public func nested(_ key: String) -> CaosProps? {
        guard let dict = data[key] as? [String: Any] else { return nil }
        return CaosProps(dict)
    }
    public func array(_ key: String) -> [CaosProps]? {
        guard let arr = data[key] as? [[String: Any]] else { return nil }
        return arr.map { CaosProps($0) }
    }
}
