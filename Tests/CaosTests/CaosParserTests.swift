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

    // MARK: - CaosProps additional paths

    func test_props_double_fromString() {
        let props = CaosProps(["val": "3.14"])
        XCTAssertEqual(props.double("val"), 3.14, accuracy: 0.001)
    }

    func test_props_double_missingKey() {
        XCTAssertEqual(CaosProps([:]).double("missing"), 0.0)
    }

    func test_props_bool_fromStringTrue() {
        XCTAssertEqual(CaosProps(["flag": "true"]).bool("flag"), true)
    }

    func test_props_bool_fromStringFalse() {
        XCTAssertEqual(CaosProps(["flag": "false"]).bool("flag"), false)
    }

    func test_props_bool_missingKey() {
        XCTAssertNil(CaosProps([:]).bool("missing"))
    }

    func test_props_nested_valid() {
        let props = CaosProps(["sub": ["key": "value"] as [String: Any]])
        XCTAssertEqual(props.nested("sub")?.string("key"), "value")
    }

    func test_props_nested_nil() {
        XCTAssertNil(CaosProps([:]).nested("missing"))
    }

    func test_props_array_valid() {
        let props = CaosProps(["items": [["id": "a"], ["id": "b"]] as [[String: Any]]])
        XCTAssertEqual(props.array("items")?.count, 2)
    }

    func test_props_array_nil() {
        XCTAssertNil(CaosProps([:]).array("missing"))
    }

    // MARK: - Deprecated API

    func test_deprecated_init_v1yaml() {
        let yaml = "version: 1\nscreens:\n  - id: home\n    container:\n      type: vertical\n    shards: []"
        let parser = CaosParser(content: yaml)
        XCTAssertEqual(parser.getScreens().count, 1)
    }

    func test_deprecated_init_legacyFallback() {
        // Non-v1 YAML triggers parseLegacy
        let content = "container: horizontal\nshard: card\n\n"
        let parser = CaosParser(content: content)
        XCTAssertEqual(parser.getScreens().count, 1)
        XCTAssertEqual(parser.getScreens()[0].containerConfig.type, "horizontal")
        XCTAssertEqual(parser.getScreens()[0].shardList.count, 1)
    }

    func test_deprecated_init_legacyFallback_emptyContainerValue() {
        // container with no value → defaults to "vertical"
        let content = "container:\nshard: card\n\n"
        let parser = CaosParser(content: content)
        XCTAssertEqual(parser.getScreens()[0].containerConfig.type, "vertical")
    }

    // MARK: - YAMLParser direct

    func test_yamlParser_parse() throws {
        let result = try YAMLParser.parse("version: 1\nscreens: []")
        XCTAssertEqual((result as? [String: Any])?["version"] as? Int, 1)
    }

    func test_yamlParser_leadingSpaces_zero() {
        XCTAssertEqual(YAMLParser.leadingSpaces("hello"), 0)
    }

    func test_yamlParser_leadingSpaces_nonzero() {
        XCTAssertEqual(YAMLParser.leadingSpaces("   hello"), 3)
    }

    func test_yamlParser_parseScalar_emptySequence() {
        XCTAssertNotNil(YAMLParser.parseScalar("[]") as? [[String: Any]])
    }

    func test_yamlParser_parseScalar_emptyMapping() {
        XCTAssertNotNil(YAMLParser.parseScalar("{}") as? [String: Any])
    }

    func test_yamlParser_parseScalar_null() {
        XCTAssertTrue(YAMLParser.parseScalar("null") is NSNull)
    }

    func test_yamlParser_parseScalar_tilde() {
        XCTAssertTrue(YAMLParser.parseScalar("~") is NSNull)
    }

    func test_yamlParser_parseScalar_doubleQuoted() {
        XCTAssertEqual(YAMLParser.parseScalar("\"hello world\"") as? String, "hello world")
    }

    func test_yamlParser_parseScalar_singleQuoted() {
        XCTAssertEqual(YAMLParser.parseScalar("'hello world'") as? String, "hello world")
    }

    func test_yamlParser_parseScalar_double() {
        XCTAssertEqual(YAMLParser.parseScalar("3.14") as? Double ?? 0, 3.14, accuracy: 0.001)
    }

    // MARK: - YAML edge cases

    func test_parse_inlineComment() throws {
        let yaml = "version: 1 # required field\nscreens: [] # empty"
        XCTAssertEqual(try CaosParser.parse(yaml).version, 1)
    }

    func test_parse_inlineComment_quotedValueWithHash() throws {
        // Exercises stripInlineComment quote-detection branches
        let yaml = "version: 1\nscreens: []\ntitle: \"value # not comment\" # real comment"
        let result = try YAMLParser.parse(yaml) as? [String: Any]
        XCTAssertEqual(result?["title"] as? String, "value # not comment")
    }

    func test_parse_commentLines() throws {
        let yaml = "# top comment\nversion: 1\n# mid comment\nscreens: []"
        XCTAssertEqual(try CaosParser.parse(yaml).version, 1)
    }

    func test_parse_spacingAsDouble() throws {
        let yaml = "version: 1\nscreens:\n  - id: s\n    container:\n      type: vertical\n      spacing: 16.5\n    shards: []"
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens[0].containerConfig.spacing, 16.5, accuracy: 0.001)
    }

    func test_parse_paddingPartialKeys() throws {
        let yaml = """
        version: 1
        screens:
          - id: s
            container:
              type: vertical
              padding:
                top: 10
            shards: []
        """
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens[0].containerConfig.padding.top, 10)
        XCTAssertEqual(schema.screens[0].containerConfig.padding.left, 0)
    }

    func test_parse_emptyValueKeyAtEnd() throws {
        // nextContentIndent returns nil when no content follows an empty-value key
        let yaml = "version: 1\norphan:\nscreens: []"
        XCTAssertEqual(try CaosParser.parse(yaml).version, 1)
    }

    func test_parse_deeperIndentSkippedInMapping() throws {
        // parseMapping skips lines with indent > current level (malformed YAML)
        let yaml = "version: 1\n    extra: malformed\nscreens: []"
        XCTAssertEqual(try CaosParser.parse(yaml).version, 1)
    }

    func test_parse_quotedKeyWithInternalColon() {
        // findKeyColon: single-quoted key containing colon — colon inside quotes is skipped
        var idx = 0
        let result = YAMLParser.parseMapping(
            lines: ["'key:colon': value"],
            index: &idx,
            indent: 0
        ) as? [String: Any]
        // Key is stored with its surrounding quotes as the parser doesn't strip them
        XCTAssertEqual(result?["'key:colon'"] as? String, "value")
    }

    func test_parse_doubleQuotedKeyWithInternalColon() {
        // findKeyColon: double-quoted key containing colon — colon inside quotes is skipped
        var idx = 0
        let result = YAMLParser.parseMapping(
            lines: ["\"key:double\": value"],
            index: &idx,
            indent: 0
        ) as? [String: Any]
        // Key is stored with its surrounding quotes as the parser doesn't strip them
        XCTAssertEqual(result?["\"key:double\""] as? String, "value")
    }

    func test_parse_lineWithoutColon_skipped() {
        // parseMapping skips lines with no valid key colon
        var idx = 0
        let result = YAMLParser.parseMapping(
            lines: ["no colon here", "valid: yes"],
            index: &idx,
            indent: 0
        ) as? [String: Any]
        XCTAssertEqual(result?["valid"] as? String, "yes")
    }

    func test_parse_sequenceWithNestedMapping() throws {
        let yaml = """
        version: 1
        screens:
          - id: home
            container:
              type: vertical
            shards:
              - type: CardView
                id: c1
                props:
                  label: Hello
                  count: 3
        """
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens[0].shardList.count, 1)
        XCTAssertEqual(schema.screens[0].shardList[0].props.string("label"), "Hello")
        XCTAssertEqual(schema.screens[0].shardList[0].props.int("count"), 3)
    }

    func test_parse_sequenceDeeperIndentSkipped() throws {
        // parseSequence skips lines with indent > sequence indent (malformed)
        let yaml = "version: 1\nscreens:\n  - id: first\n   malformed_deeper: val\n  - id: second\n    container:\n      type: vertical\n    shards: []"
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens.count, 2)
    }

    func test_parse_multipleScreens_horizontal() throws {
        let schema = try CaosParser.parse(fixture("valid_v1"))
        XCTAssertEqual(schema.screens[1].containerConfig.type, "horizontal")
        XCTAssertEqual(schema.screens[1].containerConfig.spacing, 8)
    }

    // MARK: - Parser internal edge cases

    func test_parse_blankLineBeforeSequenceItems() throws {
        // Blank line before first sequence item triggers L150 (parseBlock) and L233-234 (parseSequence)
        let yaml = "version: 1\nscreens:\n\n  - id: first\n    container:\n      type: vertical\n    shards: []\n"
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens.count, 1)
        XCTAssertEqual(schema.screens[0].id, "first")
    }

    func test_parse_singleQuotedValueWithInternalHash() throws {
        // Single-quoted string with '#' triggers L320 in stripInlineComment
        let yaml = "version: 1\nscreens: []\ntitle: 'value # not a comment'"
        let result = try YAMLParser.parse(yaml) as? [String: Any]
        XCTAssertEqual(result?["title"] as? String, "value # not a comment")
    }

    func test_parse_trailingBlankLinesAfterOrphanKey() throws {
        // Orphan key followed only by blank lines triggers L340-342 in nextContentIndent
        let yaml = "version: 1\nscreens: []\norphan:\n\n"
        XCTAssertEqual(try CaosParser.parse(yaml).version, 1)
    }

    func test_parse_sequenceItemEmptyInlineValueOnNextLines() throws {
        // Sequence item dash line has key with no inline value (value on next lines)
        // Triggers L263-269 (nested block) and L150 (blank line in parseBlock)
        let yaml = "version: 1\nscreens:\n  - id:\n\n    container:\n      type: vertical\n    shards: []\n"
        let schema = try CaosParser.parse(yaml)
        XCTAssertEqual(schema.screens.count, 1)
        XCTAssertEqual(schema.screens[0].containerConfig.type, "vertical")
    }
}
