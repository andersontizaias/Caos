import Foundation

public enum CaosError: Error, LocalizedError {
    case missingVersion
    case invalidYAML(line: Int, reason: String)
    case unsupportedVersion(Int)

    public var errorDescription: String? {
        switch self {
        case .missingVersion:
            "Caos: YAML must include 'version' as the first non-empty field."
        case let .invalidYAML(line, reason):
            "Caos: Invalid YAML at line \(line): \(reason)"
        case let .unsupportedVersion(v):
            "Caos: Unsupported schema version \(v). Expected 1."
        }
    }
}
