@testable import Caos
import XCTest

final class CaosParserTests: XCTestCase {
    // MARK: - Helpers

    private func fixture(_ name: String) -> String {
        let fileName = "\(name).yaml"
        // Try Bundle(for:) — works in Xcode test targets
        if let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "yaml") {
            return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        }
        // Direct path for SPM `swift test` (uses #filePath to locate Fixtures/)
        let path = "\(#filePath.components(separatedBy: "/Tests/").first ?? "")/Tests/CaosTests/Fixtures/\(fileName)"
        return (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
    }

    // MARK: - Happy path

    func test_parse_validV1_returnsCorrectScreenCount() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.version, 1)
        XCTAssertEqual(schema.screens.count, 2)
    }

    func test_parse_validV1_firstScreen_hasCorrectId() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.screens[0].id, "home")
    }

    func test_parse_validV1_firstScreen_containerType() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.screens[0].containerConfig.type, "vertical")
    }

    func test_parse_validV1_firstScreen_containerSpacing() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.screens[0].containerConfig.spacing, 16)
    }

    func test_parse_validV1_firstScreen_shardCount() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.screens[0].shardList.count, 2)
    }

    func test_parse_validV1_firstShard_typeAndId() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        let shard = schema.screens[0].shardList[0]
        XCTAssertEqual(shard.type, "CardView")
        XCTAssertEqual(shard.id, "card_balance")
    }

    func test_parse_validV1_firstShard_props_string() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        let props = schema.screens[0].shardList[0].props
        XCTAssertEqual(props.string("title"), "Saldo disponível")
    }

    func test_parse_validV1_firstShard_props_double() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        let props = schema.screens[0].shardList[0].props
        XCTAssertEqual(props.double("cornerRadius"), 12.0)
    }

    // MARK: - Error cases

    func test_parse_missingVersion_throwsMissingVersion() {
        XCTAssertThrowsError(try CaosParser.parse(fixture("invalid_no_version"))) { error in
            guard case CaosError.missingVersion = error else {
                return XCTFail("Expected CaosError.missingVersion, got \(error)")
            }
        }
    }

    func test_parse_unsupportedVersion_throwsUnsupportedVersion() {
        let yaml = "version: 99\nscreens: []"
        XCTAssertThrowsError(try CaosParser.parse(yaml)) { error in
            guard case CaosError.unsupportedVersion(99) = error else {
                return XCTFail("Expected CaosError.unsupportedVersion(99), got \(error)")
            }
        }
    }

    // MARK: - CaosProps

    func test_props_hexColor_sixDigitHex() {
        let props = CaosProps(["color": "#FF5500"])
        XCTAssertEqual(props.hexColor("color"), "#FF5500")
    }

    func test_props_hexColor_eightDigitHex_withAlpha() {
        let props = CaosProps(["color": "#80FF5500"])
        XCTAssertEqual(props.hexColor("color"), "#80FF5500")
    }

    func test_props_hexColor_threeDigitShorthand() {
        let props = CaosProps(["color": "#F50"])
        XCTAssertEqual(props.hexColor("color"), "#F50")
    }

    func test_props_hexColor_invalidHex_returnsNil() {
        let props = CaosProps(["color": "notacolor"])
        XCTAssertNil(props.hexColor("color"))
    }

    func test_props_double_fromInt() {
        let props = CaosProps(["val": 42])
        XCTAssertEqual(props.double("val"), 42.0)
    }

    func test_props_bool_true() {
        let props = CaosProps(["flag": true])
        XCTAssertEqual(props.bool("flag"), true)
    }

    func test_props_bool_false() {
        let props = CaosProps(["flag": false])
        XCTAssertEqual(props.bool("flag"), false)
    }

    func test_props_missingKey_returnsNil() {
        let props = CaosProps(["a": "1"])
        XCTAssertNil(props.string("b"))
    }

    // MARK: - Edge cases

    func test_parse_edgeCases_emptyShards() throws {
        let schema = try CaosParser.parse(fixture("edge_cases"))
        XCTAssertEqual(schema.screens[0].shardList.count, 0)
    }

    func test_parse_edgeCases_allPropTypes() throws {
        let schema = try CaosParser.parse(fixture("edge_cases"))
        let props = schema.screens[1].shardList[0].props
        XCTAssertEqual(props.string("stringProp"), "hello world")
        XCTAssertEqual(props.int("intProp"), 42)
        XCTAssertEqual(props.double("doubleProp"), 3.14, accuracy: 0.001)
        XCTAssertEqual(props.bool("boolPropTrue"), true)
        XCTAssertEqual(props.bool("boolPropFalse"), false)
        XCTAssertNotNil(props.hexColor("colorProp"))
        XCTAssertNotNil(props.hexColor("colorWithAlpha"))
    }
}
