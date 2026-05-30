# Caos

[![CI](https://github.com/andersontizaias/Caos/actions/workflows/ci.yml/badge.svg)](https://github.com/andersontizaias/Caos/actions/workflows/ci.yml)
[![CocoaPods](https://img.shields.io/cocoapods/v/Caos.svg)](https://cocoapods.org/pods/Caos)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![iOS](https://img.shields.io/badge/iOS-16%2B-blue)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

![Caos - The Primeval Void](./assets/caos-image.png)
*Caos — The Primeval Void in Greek Mythology*

**Caos** (**C**onfigurable **A**utomated **O**n-demand **S**creens) is an iOS Server-Driven UI framework that generates screens dynamically from YAML files. Change your UI without redeploying your app.

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                    VIEW LAYER                         │
│   CaosScreenView  ·  UIKit Shards  ·  SwiftUI Shards │
│              ↓ reads                                  │
│         @Environment(\.caosStore)                     │
├──────────────────────────────────────────────────────┤
│                   MODEL LAYER                         │
│   CaosStore — providers · publishers · shard registry │
├──────────────────────────────────────────────────────┤
│                  SCHEMA LAYER                         │
│   CaosParser  ·  CaosProps  ·  CaosSchema            │
└──────────────────────────────────────────────────────┘
```

Caos follows the **MV (Model-View)** pattern — no ViewModels. `CaosStore` is the Model; views read from it via `@Environment`.

---

## Quick Start

**1. Add YAML** (`home.yaml` in your bundle):

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
      - type: BalanceCard
        id: card_balance
        props:
          title: "Saldo disponível"
          dataKey: "user.balance"
          backgroundColor: "#FFFFFF"
          cornerRadius: 12
          textColor: "#1A1A1A"
```

**2. Register types and data** in your app:

```swift
let store = CaosStore()
store.register(type: "BalanceCard", view: BalanceCardView.self)
store.register(key: "user.balance") { UserSession.current.formattedBalance }
```

**3. Show the screen** (SwiftUI):

```swift
struct HomeView: View {
    @State private var store = CaosStore()

    var body: some View {
        CaosScreenView(name: "home")
            .caosStore(store)
    }
}
```

---

## YAML Schema Reference

| Field | Type | Required | Description |
|---|---|---|---|
| `version` | Int | ✅ | Always `1` |
| `screens` | List | ✅ | Array of screen definitions |
| `screens[].id` | String | ✅ | Unique screen identifier |
| `screens[].container.type` | String | ✅ | `vertical` \| `horizontal` \| `grid` |
| `screens[].container.spacing` | Number | — | Space between shards (pts) |
| `screens[].container.padding` | Object | — | `top`, `bottom`, `leading`, `trailing` |
| `screens[].shards` | List | — | Array of shard definitions |
| `shards[].type` | String | ✅ | Registered shard type name |
| `shards[].id` | String | — | Unique identifier (used in tap events) |
| `shards[].props` | Object | — | Typed properties passed to the shard |

### Props special keys

| Key | Type | Description |
|---|---|---|
| `dataKey` | String | Resolves value from `CaosStore` (reactive) |
| `backgroundColor` | String | Hex color `#RRGGBB` or `#AARRGGBB` |
| `textColor` | String | Hex color |
| `cornerRadius` | Number | Corner radius in points |

---

## Registering Shards

### UIKit Shard

```swift
// 1. Register in CaosStore
store.register(type: "BalanceCard", view: BalanceCardView.self)

// 2. Implement the shard
final class BalanceCardView: UIView, CaosView {
    weak var delegate: CaosEngineDelegate?
    private let binding = CaosDataBinding()
    private let label = UILabel()

    func configure(with props: CaosProps) {
        if let title = props.string("title") { titleLabel.text = title }
        if let bg = props.color("backgroundColor") { backgroundColor = bg }
        binding.bind(label: label, props: props, store: /* injected in Phase 4 */)
    }

    func showLoading() { shimmer.startShimmer() }
    func hideLoading() { shimmer.stopShimmer() }
}
```

### SwiftUI Shard

```swift
struct BalanceCardView: View, CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosStore) private var store

    var body: some View {
        VStack(alignment: .leading) {
            Text(props.string("title") ?? "")
                .font(.headline)
            Text(store.resolve(key: props.string("dataKey") ?? "") ?? "--")
                .font(.title2.bold())
                .foregroundStyle(props.swiftUIColor("textColor") ?? .primary)
        }
        .padding(props.double("padding").map(CGFloat.init) ?? 16)
        .background(props.swiftUIColor("backgroundColor") ?? Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: props.double("cornerRadius").map(CGFloat.init) ?? 12))
    }
}
```

---

## Data Binding with CaosStore

### Synchronous provider

```swift
store.register(key: "user.balance") { UserSession.current.formattedBalance }
```

### Reactive provider (Combine)

```swift
store.register(
    key: "user.balance",
    publisher: UserSession.shared.$balance
        .map { $0.formatted(.currency(code: "BRL")) }
        .eraseToAnyPublisher()
)
```

### Reactive binding in UIKit shards

```swift
private let binding = CaosDataBinding()

func configure(with props: CaosProps) {
    binding.bind(label: valueLabel, props: props, store: store)
    // valueLabel.text updates automatically whenever the store emits
}
```

---

## SwiftUI Usage

```swift
@main
struct MyApp: App {
    @State private var store = CaosStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CaosScreenView(name: "home")
                    .caosStore(store)
                    .navigationTitle("Home")
            }
            .caosStore(store)
        }
    }

    init() {
        store.register(type: "BalanceCard",  view: BalanceCardView.self)
        store.register(type: "ShortcutsRow", view: ShortcutsRowView.self)
        store.register(key: "user.balance",  provider: { UserSession.current.balance })
    }
}
```

---

## UIKit Usage

```swift
class HomeViewController: UIViewController, CaosEngineDelegate {

    var rootView: UIView { view }
    private let store = CaosStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
        guard let screen = Caos.configure(bundle: .main, name: "home", target: self, store: store)?
            .getScreenByIndex(index: 0) else { return }
        view.addSubview(screen)
        // add constraints...
    }

    private func setupStore() {
        store.register(type: "BalanceCard", view: BalanceCardView.self)
        store.register(key: "user.balance") { UserSession.current.formattedBalance }
    }

    func didTapShard(id: String, context: [String: Any]) {
        switch id {
        case "card_balance": navigateToBalance()
        default: break
        }
    }
}
```

---

## YAML Validation (CLI)

```bash
# Via SPM
swift run caos-lint home.yaml

# Output
✓ version: 1
✓ screens: 2 found
✓ shards: 5 found
⚠ Shard of type 'BannerView' in screen 'home' has no id
✅ No errors (1 warning(s))
```

---

## Migration from v0

If you're upgrading from v0, see the migration guides:

- [YAML v0 → v1](Docs/Migration_v0_to_v1.md)
- [Delegate → CaosStore](Docs/Migration_Delegate_to_Store.md)

---

## Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 5.9+

---

## Installation

### Swift Package Manager

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/andersontizaias/Caos.git", from: "1.0.0")
]
```

Or via Xcode: **File → Add Package Dependencies** and enter the repository URL.

### CocoaPods

```ruby
pod 'Caos', '~> 1.0'
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Author

**Anderson Tiago Izaias** — andersontizaias@gmail.com

---

## License

Caos is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
