//
//  CaosError.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 29/05/26.
//

import Foundation

public enum CaosError: Error, LocalizedError {
    case missingVersion
    case invalidYAML(line: Int, reason: String)
    case unsupportedVersion(Int)

    public var errorDescription: String? {
        switch self {
        case .missingVersion:
            return "Caos: YAML must include 'version' as the first non-empty field."
        case .invalidYAML(let line, let reason):
            return "Caos: Invalid YAML at line \(line): \(reason)"
        case .unsupportedVersion(let v):
            return "Caos: Unsupported schema version \(v). Expected 1."
        }
    }
}
