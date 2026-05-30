//
//  CaosParser.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

import UIKit

/// Parses YAML v1 schema files for Caos.
/// Uses only Swift stdlib — no third-party dependencies.
public class CaosParser {

    // MARK: - Public API (v1)

    /// Parses YAML content and returns a CaosSchema.
    /// Throws CaosError if the content is invalid.
    public static func parse(_ content: String) throws -> CaosSchema {
        let rawLines = content.components(separatedBy: "\n")
            .map { $0.replacingOccurrences(of: "\r", with: "") }

        var index = 0
        guard let root = YAMLParser.parseMapping(lines: rawLines, index: &index, indent: 0) as? [String: Any] else {
            throw CaosError.invalidYAML(line: 0, reason: "Root must be a mapping")
        }

        guard let version = root["version"] as? Int else {
            throw CaosError.missingVersion
        }
        guard version == 1 else {
            throw CaosError.unsupportedVersion(version)
        }

        let screensRaw = root["screens"] as? [[String: Any]] ?? []
        let screens = screensRaw.map { parseScreen($0) }
        return CaosSchema(version: version, screens: screens)
    }

    // MARK: - Private helpers

    private static func parseScreen(_ dict: [String: Any]) -> CaosScreen {
        let screen = CaosScreen()
        screen.id = dict["id"] as? String ?? ""

        if let containerDict = dict["container"] as? [String: Any] {
            let type = containerDict["type"] as? String ?? "vertical"
            let spacing: CGFloat
            if let d = containerDict["spacing"] as? Double {
                spacing = CGFloat(d)
            } else if let i = containerDict["spacing"] as? Int {
                spacing = CGFloat(i)
            } else {
                spacing = 0
            }

            var top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0
            if let paddingDict = containerDict["padding"] as? [String: Any] {
                top      = cgfloat(from: paddingDict["top"])
                bottom   = cgfloat(from: paddingDict["bottom"])
                leading  = cgfloat(from: paddingDict["leading"])
                trailing = cgfloat(from: paddingDict["trailing"])
            }
            screen.containerConfig = CaosContainer(
                type: type,
                spacing: spacing,
                padding: UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
            )
        }

        if let shardsRaw = dict["shards"] as? [[String: Any]] {
            screen.shardList = shardsRaw.map { parseShard($0) }
        }
        return screen
    }

    private static func cgfloat(from value: Any?) -> CGFloat {
        if let d = value as? Double { return CGFloat(d) }
        if let i = value as? Int { return CGFloat(i) }
        return 0
    }

    private static func parseShard(_ dict: [String: Any]) -> CaosShard {
        let type  = dict["type"] as? String ?? ""
        let id    = dict["id"]   as? String ?? ""
        let props = CaosProps(dict["props"] as? [String: Any] ?? [:])
        return CaosShard(type: type, id: id, props: props)
    }

    // MARK: - Deprecated v0 API (backward compat with existing CaosEngine)

    private var _screens: [CaosScreen] = []

    @available(*, deprecated, message: "Use CaosParser.parse(_:) instead")
    public init(content: String) {
        if let schema = try? CaosParser.parse(content) {
            _screens = schema.screens
        } else {
            // Fallback: legacy flat parser for v0 files
            _screens = CaosParser.parseLegacy(content)
        }
    }

    @available(*, deprecated, message: "Use CaosParser.parse(_:) instead")
    public func getScreens() -> [CaosScreen] { _screens }

    /// Legacy flat parser for v0 YAML format (container_type / shard lines).
    private static func parseLegacy(_ content: String) -> [CaosScreen] {
        let lines = content.components(separatedBy: "\n")
        var screens: [CaosScreen] = []
        var screen: CaosScreen?

        for (index, line) in lines.enumerated() {
            if line.contains("container") {
                screen = CaosScreen()
                let value = line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                screen?.containerConfig = CaosContainer(type: value.isEmpty ? "vertical" : value)
            }
            if line.contains("shard") {
                let value = line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                screen?.shardList.append(CaosShard(type: value))
            }
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || index == lines.count - 1 {
                if let scr = screen {
                    screens.append(scr)
                    screen = nil
                }
            }
        }
        return screens
    }
}

// MARK: - Internal YAML tree parser (stdlib only)

enum YAMLParser {

    // MARK: - Public entry point

    /// Parse YAML content, returning a mapping or sequence as Any.
    static func parse(_ content: String) throws -> Any {
        let lines = content.components(separatedBy: "\n")
            .map { $0.replacingOccurrences(of: "\r", with: "") }
        var index = 0
        return parseBlock(lines: lines, index: &index, indent: 0) ?? [String: Any]()
    }

    // MARK: - Block dispatcher

    /// Returns either [String:Any] (mapping) or [[String:Any]] (sequence), or nil.
    static func parseBlock(lines: [String], index: inout Int, indent: Int) -> Any? {
        // Skip blank / comment lines to peek at what kind of block this is
        var peek = index
        while peek < lines.count {
            let t = lines[peek].trimmingCharacters(in: .whitespaces)
            if t.isEmpty || t.hasPrefix("#") { peek += 1; continue }
            let li = leadingSpaces(lines[peek])
            if li < indent { return nil }
            if t.hasPrefix("-") {
                return parseSequence(lines: lines, index: &index, indent: indent)
            } else {
                return parseMapping(lines: lines, index: &index, indent: indent)
            }
        }
        return nil
    }

    // MARK: - Mapping parser

    /// Parse a YAML mapping at exactly `indent` spaces. Returns [String: Any].
    static func parseMapping(lines: [String], index: inout Int, indent: Int) -> Any {
        var result: [String: Any] = [:]

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Skip blank lines and comments
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                index += 1
                continue
            }

            let li = leadingSpaces(line)

            // Dedent means we're done with this mapping level
            if li < indent { break }

            // A deeper indent level that isn't a continuation means something is wrong — skip
            if li > indent { index += 1; continue }

            // A sequence item at this level means we've stepped into a sequence context — stop
            if trimmed.hasPrefix("-") { break }

            // Parse key: value
            guard let colonRange = findKeyColon(trimmed) else {
                index += 1
                continue
            }

            let key = String(trimmed[trimmed.startIndex..<colonRange]).trimmingCharacters(in: .whitespaces)
            let rest = String(trimmed[trimmed.index(after: colonRange)...]).trimmingCharacters(in: .whitespaces)

            index += 1

            if rest.isEmpty || rest == "|" || rest == ">" {
                // Value is on subsequent indented lines — look ahead
                let childIndent = nextContentIndent(lines: lines, from: index)
                if let ci = childIndent, ci > indent {
                    if let val = parseBlock(lines: lines, index: &index, indent: ci) {
                        result[key] = val
                    }
                }
                // If no child content, value is nil/empty — skip key
            } else {
                // Check for inline comment
                let scalar = stripInlineComment(rest)
                result[key] = parseScalar(scalar)
            }
        }
        return result
    }

    // MARK: - Sequence parser

    /// Parse a YAML sequence (list of `-` items) at exactly `indent` spaces.
    /// Returns [[String: Any]].
    private static func parseSequence(lines: [String], index: inout Int, indent: Int) -> [[String: Any]] {
        var result: [[String: Any]] = []

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                index += 1
                continue
            }

            let li = leadingSpaces(line)
            if li < indent { break }
            if li > indent { index += 1; continue }  // malformed deeper indent — skip
            guard trimmed.hasPrefix("-") else { break }

            // Consume the dash line
            index += 1

            // Content after the dash (may be inline key: value)
            let afterDash = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)

            // The body of this item lives at indent+2 (standard YAML list item indent)
            let itemBodyIndent = indent + 2

            var itemDict: [String: Any] = [:]

            // Parse inline key: value on the dash line
            if !afterDash.isEmpty && !afterDash.hasPrefix("#") {
                if let colonRange = findKeyColon(afterDash) {
                    let inlineKey = String(afterDash[afterDash.startIndex..<colonRange]).trimmingCharacters(in: .whitespaces)
                    let inlineRest = String(afterDash[afterDash.index(after: colonRange)...]).trimmingCharacters(in: .whitespaces)
                    if inlineRest.isEmpty {
                        // value is on next lines at itemBodyIndent
                        if let ci = nextContentIndent(lines: lines, from: index), ci >= itemBodyIndent {
                            if let val = parseBlock(lines: lines, index: &index, indent: ci) {
                                itemDict[inlineKey] = val
                            }
                        }
                    } else {
                        itemDict[inlineKey] = parseScalar(stripInlineComment(inlineRest))
                    }
                }
            }

            // Parse remaining key-value pairs for this item at itemBodyIndent
            let more = parseMapping(lines: lines, index: &index, indent: itemBodyIndent) as? [String: Any] ?? [:]
            for (k, v) in more { itemDict[k] = v }

            // Handle empty sequence items `[]`
            result.append(itemDict)
        }
        return result
    }

    // MARK: - Helpers

    /// Find the colon that delimits a YAML key (not inside quotes).
    private static func findKeyColon(_ s: String) -> String.Index? {
        var inSingleQuote = false
        var inDoubleQuote = false
        var i = s.startIndex
        while i < s.endIndex {
            let c = s[i]
            if c == "'" && !inDoubleQuote { inSingleQuote.toggle() }
            else if c == "\"" && !inSingleQuote { inDoubleQuote.toggle() }
            else if c == ":" && !inSingleQuote && !inDoubleQuote {
                // Make sure this is a key colon (followed by space, end of string, or end)
                let next = s.index(after: i)
                if next == s.endIndex || s[next] == " " || s[next] == "\t" {
                    return i
                }
            }
            i = s.index(after: i)
        }
        return nil
    }

    /// Strip inline YAML comment (# preceded by space).
    private static func stripInlineComment(_ s: String) -> String {
        // Only strip if there's a space before #
        var inSingle = false, inDouble = false
        var prev: Character = " "
        var i = s.startIndex
        while i < s.endIndex {
            let c = s[i]
            if c == "'" && !inDouble { inSingle.toggle() }
            else if c == "\"" && !inSingle { inDouble.toggle() }
            else if c == "#" && !inSingle && !inDouble && (prev == " " || prev == "\t") {
                return String(s[s.startIndex..<i]).trimmingCharacters(in: .whitespaces)
            }
            prev = c
            i = s.index(after: i)
        }
        return s
    }

    /// Find the indent of the next non-blank, non-comment line at or after `from`.
    private static func nextContentIndent(lines: [String], from: Int) -> Int? {
        var i = from
        while i < lines.count {
            let t = lines[i].trimmingCharacters(in: .whitespaces)
            if !t.isEmpty && !t.hasPrefix("#") {
                return leadingSpaces(lines[i])
            }
            i += 1
        }
        return nil
    }

    /// Parse a scalar YAML value into Int, Double, Bool, or String.
    static func parseScalar(_ s: String) -> Any {
        // Handle empty sequence shorthand
        if s == "[]" { return [[String: Any]]() }
        if s == "{}" { return [String: Any]() }

        // Remove surrounding quotes
        if s.count >= 2 {
            if (s.hasPrefix("\"") && s.hasSuffix("\"")) ||
               (s.hasPrefix("'") && s.hasSuffix("'")) {
                return String(s.dropFirst().dropLast())
            }
        }
        if s == "true" { return true }
        if s == "false" { return false }
        if s == "null" || s == "~" { return NSNull() }
        if let i = Int(s) { return i }
        if let d = Double(s) { return d }
        return s
    }

    /// Count leading space characters in a string.
    static func leadingSpaces(_ s: String) -> Int {
        var count = 0
        for c in s { if c == " " { count += 1 } else { break } }
        return count
    }
}
