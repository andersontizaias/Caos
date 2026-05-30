# Contributing to Caos

Thank you for your interest in contributing! Please follow the guidelines below.

## Environment setup

```bash
# Clone and enter the directory
git clone https://github.com/andersontizaias/Caos.git
cd Caos

# Generates Caos.xcodeproj and CaosExample.xcodeproj (requires Homebrew)
make setup

# Opens directly in Xcode
make open
```

`Caos.xcodeproj` is **generated** by XcodeGen and is not versioned. The source of truth is `project.yml`.

## Workflow

1. Fork the repository and create your branch from `develop`:
   ```bash
   git checkout develop
   git checkout -b feature/my-feature
   ```

2. Implement your change following the guidelines below

3. Make sure tests pass and coverage is ≥ 90%:
   ```bash
   swift test --enable-code-coverage
   ```

4. Open a Pull Request to `develop` with a title following the Conventional Commits format

## Code standards

- **MV architecture**: no ViewModels. Views read from `CaosStore` via `@Environment`
- **SwiftLint**: `swiftlint --strict` must pass with 0 violations
- **SwiftFormat**: `swiftformat --lint Sources Tests` must report no changes needed
- **iOS 16+**: do not use APIs exclusive to iOS 17+ without an availability guard
- **Stdlib only in the parser**: `CaosParser` must have no external dependencies

## Adding a new shard type

1. Create your view conforming to `CaosSwiftUIView`
2. Document the accepted `CaosProps` with types and default values
3. Register via `CaosStore.register(type:view:)` in the consumer app
4. Add unit tests covering the props

## Adding support for new props

1. Accept the new field in `var body: some View` via `props.string()`, `props.double()`, etc.
2. Never silently fall back — use `?? defaultValue` explicitly
3. Update the README with the new prop in the reference table

## Tests

- Minimum coverage: **90%** per new file
- Tests must use concrete mocks — no force unwrap in tests
- YAML fixtures go in `Tests/CaosTests/Fixtures/`

## Commits — Conventional Commits

Every commit and PR title **must** follow the [Conventional Commits](https://www.conventionalcommits.org/) standard. Danger blocks PRs that don't follow the format.

### Format

```
<type>(<optional scope>): <short description>

[optional body]

[BREAKING CHANGE: <description> — optional]
```

### Valid types

| Type | When to use |
|---|---|
| `feat` | New user-facing functionality |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no behaviour change |
| `refactor` | Refactoring with no behaviour change |
| `test` | Adding or fixing tests |
| `chore` | CI, dependencies, configuration, build |
| `perf` | Performance improvement |
| `ci` | Changes specific to CI workflows |
| `build` | Build system, Package.swift, XcodeGen |
| `revert` | Reverts a previous commit |

### Examples

```bash
feat: add horizontal grid container support
fix(parser): fix crash with YAML missing version field
docs: add reactive binding example to README
chore: update XcodeGen to 2.43.0
feat!: drop YAML v0 support          # breaking change
```

### Breaking changes

Add `!` after the type or include `BREAKING CHANGE:` in the commit body to signal that the major version should be incremented.

## Code of conduct

Be respectful. Constructive criticism is welcome; personal attacks are not.
