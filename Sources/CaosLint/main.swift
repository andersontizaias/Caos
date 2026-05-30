import Caos
import Foundation

// MARK: - caos-lint CLI

// Validates a Caos YAML v1 file and reports issues.
// Usage: swift run caos-lint <path-to-yaml>

struct LintResult {
    var errors: [String] = []
    var warnings: [String] = []
}

func lint(filePath: String) -> LintResult {
    var result = LintResult()

    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        result.errors.append("Could not read file: \(filePath)")
        return result
    }

    let schema: CaosSchema
    do {
        schema = try CaosParser.parse(content)
    } catch CaosError.missingVersion {
        result.errors.append("Missing 'version' field — YAML v1 requires version: 1 as the first key")
        return result
    } catch let CaosError.unsupportedVersion(v) {
        result.errors.append("Unsupported schema version \(v) — expected 1")
        return result
    } catch {
        result.errors.append("Parse error: \(error.localizedDescription)")
        return result
    }

    print("✓ version: \(schema.version)")
    print("✓ screens: \(schema.screens.count) found")

    var totalShards = 0
    var shardIds = Set<String>()

    for screen in schema.screens {
        for shard in screen.shardList {
            totalShards += 1

            if shard.type.isEmpty {
                result.errors.append("Screen '\(screen.id)': shard missing 'type' field")
            }

            if !shard.id.isEmpty {
                if shardIds.contains(shard.id) {
                    result.errors.append("Duplicate shard id '\(shard.id)' in screen '\(screen.id)'")
                } else {
                    shardIds.insert(shard.id)
                }
            } else {
                result.warnings.append("Shard of type '\(shard.type)' in screen '\(screen.id)' has no id")
            }
        }
    }

    print("✓ shards: \(totalShards) found")
    return result
}

// MARK: - Entry point

let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: caos-lint <yaml-file>")
    print("Example: caos-lint caos.yaml")
    exit(1)
}

let filePath = args[1]
let result = lint(filePath: filePath)

for warning in result.warnings {
    print("⚠ \(warning)")
}

for error in result.errors {
    print("✗ \(error)")
}

if result.errors.isEmpty, result.warnings.isEmpty {
    print("✅ No issues found")
    exit(0)
} else if result.errors.isEmpty {
    print("✅ No errors (\(result.warnings.count) warning(s))")
    exit(0)
} else {
    exit(1)
}
