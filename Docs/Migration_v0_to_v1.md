# Migration Guide: Caos v0 → v1

This guide covers migrating from the original Caos YAML format (v0) to the structured v1 schema introduced in Phase 1 of the Caos evolution.

---

## 1. The v0 YAML Format and Why It's Deprecated

The v0 format was a flat, loosely-structured YAML file parsed by simple line-by-line string matching. It had no version marker, no typed container configuration, and no structured shard properties.

**v0 example (`caos.yaml`):**
```yaml
container: vertical

shard: CaosViewCard
shard: CaosViewShortcutsChain
```

**Problems with v0:**
- No schema version — impossible to evolve the format safely.
- Container is a bare string key; no spacing, padding, or layout config.
- Shards are bare class names resolved via `NSClassFromString` — fragile, Swift-hostile, and breaks with module renaming.
- No typed properties per shard — no way to pass data from YAML to UI components.
- Parser relies on `contains("container")` / `contains("shard")` substring matching — error-prone.

---

## 2. The v1 YAML Format (Side by Side)

| Aspect | v0 | v1 |
|---|---|---|
| Version field | None | `version: 1` (required, first key) |
| Screens | Implicit (one per blank-line block) | Explicit `screens:` sequence |
| Screen ID | None | `id: home` |
| Container | `container: vertical` (string) | Structured mapping with `type`, `spacing`, `padding` |
| Shards | `shard: ClassName` (string) | Structured mapping with `type`, `id`, `props` |
| Props | None | Typed key-value mapping under each shard |

**v1 example:**
```yaml
version: 1
screens:
  - id: home
    container:
      type: vertical
      spacing: 16
      padding:
        top: 24
        bottom: 24
        leading: 16
        trailing: 16
    shards:
      - type: CardView
        id: card_balance
        props:
          title: "Saldo disponível"
          backgroundColor: "#FFFFFF"
          cornerRadius: 12
```

---

## 3. `NSClassFromString` → Type Registration Migration

In v0, `CaosEngine` instantiated shard views using `NSClassFromString(className)`, which required:
- The class name to match the Objective-C runtime name exactly (including module prefix in Swift).
- All shard view classes to be `@objc`-exposed.
- No Swift-only types (structs, generic views, SwiftUI views).

In v1, the `type` field in a shard is an **identifier string** — not a class name. The framework (in a future phase) will use a registered type-to-factory mapping:

```swift
// Future API (Phase 3+)
CaosEngine.register(type: "CardView") { shard in
    let view = MyCardView()
    view.configure(with: shard.props)
    return view
}
```

**Migration steps for shard view classes:**
1. Rename shard view classes to match your preferred `type` identifier in YAML (or keep the class name and register it explicitly).
2. Remove `@objc` annotations that were only needed for `NSClassFromString`.
3. Implement a configure method accepting `CaosProps` instead of reading raw strings.

---

## 4. Deprecated API Changes

### `CaosParser`

| v0 API | v1 Replacement | Status |
|---|---|---|
| `CaosParser(content:)` | `CaosParser.parse(_:) throws -> CaosSchema` | Deprecated |
| `parser.getScreens()` | `schema.screens` (on returned `CaosSchema`) | Deprecated |

The deprecated init and `getScreens()` are preserved for backward compatibility and will attempt to parse v1 YAML first, falling back to the legacy flat parser for v0 files.

### `CaosScreen`

| v0 Property | v1 Replacement | Status |
|---|---|---|
| `screen.container: String` | `screen.containerConfig: CaosContainer` | Deprecated |
| `screen.shards: [String]` | `screen.shardList: [CaosShard]` | Deprecated |

The deprecated properties forward to the v1 backing storage:
- `screen.container` → reads/writes `screen.containerConfig.type`
- `screen.shards` → reads `shardList.map { $0.type }`, writes create `CaosShard(type:)` entries

---

## 5. Step-by-Step Migration Instructions

### Step 1 — Add `version: 1` to your YAML

Add `version: 1` as the very first key in your YAML file.

### Step 2 — Wrap screens in the `screens:` sequence

Convert each implicit screen block (separated by blank lines) into an explicit list item under `screens:`.

### Step 3 — Convert the container to a structured mapping

Replace:
```yaml
container: vertical
```
With:
```yaml
container:
  type: vertical
  spacing: 0
  padding:
    top: 0
    bottom: 0
    leading: 0
    trailing: 0
```

### Step 4 — Convert shards to structured mappings

Replace:
```yaml
shard: CaosViewCard
```
With:
```yaml
shards:
  - type: CardView
    id: my_card
    props:
      title: "My Title"
```

### Step 5 — Switch to the v1 parsing API

Replace:
```swift
let parser = CaosParser(content: yamlString)
let screens = parser.getScreens()
```
With:
```swift
let schema = try CaosParser.parse(yamlString)
let screens = schema.screens
```

Handle `CaosError` cases appropriately:
```swift
do {
    let schema = try CaosParser.parse(yamlString)
    // use schema.screens
} catch CaosError.missingVersion {
    // YAML file has no version field
} catch CaosError.unsupportedVersion(let v) {
    // version \(v) is not supported
} catch CaosError.invalidYAML(let line, let reason) {
    // syntax error at line \(line): \(reason)
}
```

### Step 6 — Access typed props in shard views

In your shard view, instead of hardcoded values, read from `CaosProps`:
```swift
func configure(with props: CaosProps) {
    titleLabel.text = props.string("title")
    backgroundColor = props.color("backgroundColor") ?? .white
    layer.cornerRadius = props.double("cornerRadius").map { CGFloat($0) } ?? 0
}
```

---

## Summary

| Task | v0 | v1 |
|---|---|---|
| Parse YAML | `CaosParser(content:)` | `try CaosParser.parse(_:)` |
| Access screens | `parser.getScreens()` | `schema.screens` |
| Screen container | `screen.container` (String) | `screen.containerConfig` (CaosContainer) |
| Screen shards | `screen.shards` ([String]) | `screen.shardList` ([CaosShard]) |
| Shard props | None | `shard.props` (CaosProps) |
| View instantiation | `NSClassFromString` | Type registry (Phase 3+) |
