@testable import Caos
import XCTest

final class CaosErrorTests: XCTestCase {
    func test_missingVersion_errorDescription() {
        XCTAssertEqual(
            CaosError.missingVersion.errorDescription,
            "Caos: YAML must include 'version' as the first non-empty field."
        )
    }

    func test_invalidYAML_errorDescription() {
        let error = CaosError.invalidYAML(line: 5, reason: "unexpected token")
        XCTAssertEqual(error.errorDescription, "Caos: Invalid YAML at line 5: unexpected token")
    }

    func test_unsupportedVersion_errorDescription() {
        XCTAssertEqual(
            CaosError.unsupportedVersion(42).errorDescription,
            "Caos: Unsupported schema version 42. Expected 1."
        )
    }
}
