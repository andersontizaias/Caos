# Caos Framework — Plano de Migração SwiftUI Nativo

## Contexto e Motivação

O framework Caos nunca foi lançado publicamente. A versão atual usa UIKit internamente
(`CaosEngine`, `UIScrollView`, `UIStackView`, `CaosView: UIView`) com uma camada
`UIViewRepresentable` como ponte para SwiftUI. Isso introduz `#if canImport(UIKit)` em
todo o código, complica o build via SPM no macOS e contradiz a proposta de ser um
framework SwiftUI moderno.

**Decisão**: migrar o motor de rendering para SwiftUI nativo, eliminando UIKit do framework.
Sem compatibilidade retroativa — o framework será re-lançado como v1.0.

---

## Estado Atual (antes da migração)

### Camada UIKit (a eliminar)

| Arquivo | Papel atual | Destino |
|---|---|---|
| `Core/Caos.swift` | Entry point — lê bundle e cria `CaosEngine` | Deletar |
| `Core/CaosEngine.swift` | Cria `UIScrollView` + `UIStackView` + shards | Deletar |
| `Core/CaosDataBinding.swift` | Bind `UILabel` a `CaosStore` via Combine | Deletar |
| `UI/CaosView.swift` | `protocol CaosView: UIView` | Deletar |
| `UI/CaosShimmerView.swift` | `UIView` com `CAGradientLayer` | Deletar |
| `UI/CaosEngineDelegate.swift` | Protocolo com `rootView: UIView` | Deletar |
| `SwiftUI/CaosCoordinator.swift` | `NSObject, CaosEngineDelegate` — bridge UIKit | Deletar |
| `SwiftUI/CaosScreenView.swift` | `UIViewRepresentable` wrapping UIScrollView | Reescrever |

### Camada cross-platform (manter)

| Arquivo | Papel | Mudanças |
|---|---|---|
| `Schema/CaosParser.swift` | Parser YAML v1 stdlib-only | Remover `UIEdgeInsets` — já substituído por `CaosEdgeInsets` |
| `Schema/CaosProps.swift` | Acesso tipado a propriedades YAML | Remover `UIColor`/`Color` — app usa suas próprias cores |
| `Schema/CaosScreen.swift` | `CaosScreen`, `CaosContainer`, `CaosEdgeInsets` | Remover props deprecated do v0 |
| `Schema/CaosShard.swift` | `CaosShard` com type, id, props | Sem mudanças |
| `Schema/CaosSchema.swift` | `CaosSchema` com version + screens | Sem mudanças |
| `Core/CaosError.swift` | Erros tipados do parser | Sem mudanças |
| `Core/CaosStore.swift` | Model central — Combine + type registry | Refatorar: remover `CaosView.Type`, usar factory closures |

---

## Arquitetura Alvo

```
App
 │
 ├── CaosScreenView(name: "home", bundle: .main)  ← SwiftUI View nativa
 │       @Environment(\.caosStore) var store
 │
 │   CaosScreenView.body:
 │       CaosContainerView(screen: parsedScreen)
 │           ScrollView
 │               LazyVStack / LazyHStack / LazyVGrid
 │                   ForEach(screen.shardList) { shard in
 │                       store.view(for: shard.type, props: shard.props)
 │                   }
 │
 └── CaosStore (Model — @Observable / ObservableObject)
         shardRegistry: [String: (CaosProps) -> AnyView]   ← type-erased factory
         providers:     [String: () -> Any]                 ← data providers
         subjects:      [String: CurrentValueSubject<...>]  ← publishers Combine
```

### Protocolo de shard

```swift
// O app registra shards assim:
store.register(type: "card") { props in CardView(props: props) }

// Ou via protocol para garantir init(props:):
store.register(type: "card", view: CardView.self)  // onde CardView: CaosSwiftUIView
```

### Tap handling via Environment (sem delegate)

```swift
// No app:
CaosScreenView(name: "home")
    .onCaosTap { id, context in
        navigator.push(id)
    }

// Dentro do shard:
@Environment(\.caosTapAction) var onTap
Button { onTap(props.string("id") ?? "", [:]) } label: { ... }
```

---

## Regras Arquiteturais (MV — obrigatórias)

1. **Sem UIKit no framework** — nenhum `import UIKit`, nenhum `UIView`, nenhum
   `UIViewRepresentable`, nenhum `#if canImport(UIKit)`
2. **Sem ViewModel** — nenhuma classe com sufixo `ViewModel` ou que implemente
   `ObservableObject` por conta própria; o único Model é `CaosStore`
3. **Shards são structs SwiftUI** — conformam `CaosSwiftUIView: View` com `init(props:)`
4. **Dados via @Environment** — shards lêem store e tap handler via `@Environment`,
   sem parâmetros adicionais além de `props`
5. **Parser é puro Swift** — nenhum import de framework de UI no schema layer

---

## Fases de Implementação

---

### Fase 0 — Limpeza e Remoção do UIKit

**Objetivo**: deletar toda a camada UIKit e preparar a estrutura de pastas limpa.

**Arquivos a deletar**:
```
Sources/Caos/Core/Caos.swift
Sources/Caos/Core/CaosEngine.swift
Sources/Caos/Core/CaosDataBinding.swift
Sources/Caos/UI/CaosView.swift
Sources/Caos/UI/CaosShimmerView.swift
Sources/Caos/UI/CaosEngineDelegate.swift
Sources/Caos/SwiftUI/CaosCoordinator.swift
```

**Arquivos a limpar**:

`Schema/CaosScreen.swift`:
- Deletar as `@available(*, deprecated)` props `container` e `shards`
- `CaosContainer` e `CaosEdgeInsets` permanecem — são usados pela nova rendering layer

`Schema/CaosProps.swift`:
- Deletar os métodos `color(_:)` e `swiftUIColor(_:)` — UIKit/SwiftUI Color
- O app converte `props.string("color")` para a cor que quiser
- Deletar o bloco `#if canImport(UIKit)` inteiro e a extensão `UIColor`

`Core/CaosStore.swift`:
- Deletar `private var shardRegistry: [String: any CaosView.Type]`
- Deletar `func register(type:view:)` que aceita `CaosView.Type`
- Deletar `func viewType(for:)`
- Manter `providers`, `subjects`, `register(key:provider:)`, `register(key:publisher:)`,
  `resolve(key:)`, `publisher(for:)`
- Adicionar novo registry baseado em factory closures (Fase 1)

**Resultado**: o projeto não compila (tipos ausentes) — é o estado esperado para a Fase 1.

**Commit**: `[Phase 0] Remove UIKit layer — CaosEngine, CaosView, CaosDataBinding deleted`

---

### Fase 1 — CaosStore com Factory Registry

**Objetivo**: substituir o registry baseado em `UIView.Type` por factory closures type-erased,
sem dependência de UIKit.

**Contrato final de `CaosStore`**:

```swift
import Foundation
import Combine

public final class CaosStore: ObservableObject {

    // MARK: - Shard registry (type-erased factories)
    private var shardRegistry: [String: (CaosProps) -> AnyView] = [:]

    // MARK: - Data layer
    private var providers: [String: () -> Any] = [:]
    private var subjects: [String: CurrentValueSubject<Any, Never>] = [:]
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    // MARK: - Shard registration

    /// Registra um shard via closure type-erased — máxima flexibilidade.
    public func register(type: String, factory: @escaping (CaosProps) -> AnyView) {
        shardRegistry[type] = factory
    }

    /// Registra um shard via tipo que conforma CaosSwiftUIView — sintaxe conveniente.
    public func register<V: CaosSwiftUIView>(type: String, view: V.Type) {
        shardRegistry[type] = { props in AnyView(V(props: props)) }
    }

    /// Instancia a view para um shard. Retorna CaosUnknownShardView se tipo não registrado.
    public func view(for type: String, props: CaosProps) -> AnyView {
        guard let factory = shardRegistry[type] else {
            return AnyView(CaosUnknownShardView(type: type))
        }
        return factory(props)
    }

    // MARK: - Data registration (sem mudanças)
    public func register<T>(key: String, provider: @escaping () -> T) { ... }
    public func register<T>(key: String, publisher: AnyPublisher<T, Never>) { ... }
    public func resolve<T>(key: String) -> T? { ... }
    public func publisher<T>(for key: String) -> AnyPublisher<T, Never>? { ... }
}
```

**Arquivo novo**: `Sources/Caos/SwiftUI/CaosUnknownShardView.swift`

```swift
/// Renderizado quando um tipo de shard não está registrado no CaosStore.
/// Visível apenas em debug — em release pode ser EmptyView.
struct CaosUnknownShardView: View {
    let type: String
    var body: some View {
        #if DEBUG
        Text("⚠ Shard '\(type)' não registrado")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(8)
        #else
        EmptyView()
        #endif
    }
}
```

**Commit**: `[Phase 1] CaosStore factory registry — type-erased shard factories, no UIKit`

---

### Fase 2 — CaosSwiftUIView e Tap Handler

**Objetivo**: definir o protocolo público de shards e o mecanismo de eventos.

**`Sources/Caos/SwiftUI/CaosSwiftUIView.swift`** (reescrever):

```swift
import SwiftUI

/// Protocolo que todo shard SwiftUI deve conformar.
/// O shard recebe props do YAML e acessa dados via @Environment(\.caosStore).
///
/// Exemplo:
/// ```swift
/// struct CardView: CaosSwiftUIView {
///     let props: CaosProps
///     @Environment(\.caosStore) var store
///     @Environment(\.caosTapAction) var onTap
///
///     var body: some View {
///         Button { onTap(props.string("id") ?? "", [:]) } label: {
///             Text(props.string("title") ?? "")
///         }
///     }
/// }
/// ```
public protocol CaosSwiftUIView: View {
    init(props: CaosProps)
}
```

**`Sources/Caos/SwiftUI/CaosTapHandler.swift`** (novo):

```swift
import SwiftUI

public typealias CaosTapAction = (String, [String: Any]) -> Void

private struct CaosTapActionKey: EnvironmentKey {
    static let defaultValue: CaosTapAction = { _, _ in }
}

public extension EnvironmentValues {
    var caosTapAction: CaosTapAction {
        get { self[CaosTapActionKey.self] }
        set { self[CaosTapActionKey.self] = newValue }
    }
}

public extension View {
    /// Define o handler de toque para todos os shards descendentes.
    /// O `id` vem do campo `id:` do shard no YAML.
    func onCaosTap(_ action: @escaping CaosTapAction) -> some View {
        environment(\.caosTapAction, action)
    }
}
```

**Commit**: `[Phase 2] CaosSwiftUIView protocol + tap handler via Environment`

---

### Fase 3 — CaosContainerView e CaosScreenView Nativo

**Objetivo**: implementar o motor de rendering em SwiftUI puro — o coração da migração.

**`Sources/Caos/SwiftUI/CaosContainerView.swift`** (novo):

```swift
import SwiftUI

/// Renderiza um CaosScreen usando containers SwiftUI nativos.
/// Escolhe ScrollView + VStack / HStack / LazyVGrid baseado em containerConfig.type.
struct CaosContainerView: View {
    let screen: CaosScreen
    @Environment(\.caosStore) var store

    var body: some View {
        ScrollView(scrollAxis) {
            containerStack
                .padding(
                    EdgeInsets(
                        top: screen.containerConfig.padding.top,
                        leading: screen.containerConfig.padding.left,
                        bottom: screen.containerConfig.padding.bottom,
                        trailing: screen.containerConfig.padding.right
                    )
                )
        }
    }

    // MARK: - Private

    private var shards: some View {
        ForEach(screen.shardList, id: \.id) { shard in
            store.view(for: shard.type, props: shard.props)
        }
    }

    private var scrollAxis: Axis.Set {
        screen.containerConfig.type == "horizontal" ? .horizontal : .vertical
    }

    @ViewBuilder
    private var containerStack: some View {
        switch screen.containerConfig.type {
        case "horizontal":
            LazyHStack(spacing: screen.containerConfig.spacing) { shards }
        case "grid":
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: screen.containerConfig.spacing
            ) { shards }
        default: // "vertical"
            LazyVStack(spacing: screen.containerConfig.spacing) { shards }
        }
    }
}
```

**`Sources/Caos/SwiftUI/CaosScreenView.swift`** (reescrever — remover UIViewRepresentable):

```swift
import SwiftUI

/// View SwiftUI que carrega e renderiza uma tela Caos a partir de um arquivo YAML.
///
/// Uso básico:
/// ```swift
/// CaosScreenView(name: "home")
///     .caosStore(store)
///     .onCaosTap { id, context in
///         navigator.push(id)
///     }
/// ```
public struct CaosScreenView: View {

    private let name: String
    private let bundle: Bundle

    @Environment(\.caosStore) private var store
    @State private var schema: CaosSchema?
    @State private var error: CaosError?

    public init(name: String, bundle: Bundle = .main) {
        self.name = name
        self.bundle = bundle
    }

    public var body: some View {
        Group {
            if let schema {
                // Renderiza apenas a primeira tela (index 0)
                if let screen = schema.screens.first {
                    CaosContainerView(screen: screen)
                }
            } else if let error {
                CaosErrorView(error: error)
            } else {
                ProgressView()
            }
        }
        .task { await loadSchema() }
    }

    // MARK: - Private

    @MainActor
    private func loadSchema() async {
        guard let path = bundle.path(forResource: name, ofType: "yaml") else {
            error = .invalidYAML(line: 0, reason: "'\(name).yaml' não encontrado no bundle")
            return
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            schema = try CaosParser.parse(content)
        } catch let caosErr as CaosError {
            error = caosErr
        } catch {
            self.error = .invalidYAML(line: 0, reason: error.localizedDescription)
        }
    }
}

/// View interna exibida quando o parse do YAML falha.
private struct CaosErrorView: View {
    let error: CaosError
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
```

**Commit**: `[Phase 3] CaosContainerView + CaosScreenView nativo — sem UIViewRepresentable`

---

### Fase 4 — Shimmer SwiftUI Nativo

**Objetivo**: substituir `CaosShimmerView (UIView + CAGradientLayer)` por um
SwiftUI `ViewModifier` baseado em `TimelineView` e animação de gradiente.

**`Sources/Caos/SwiftUI/CaosShimmerModifier.swift`** (novo):

```swift
import SwiftUI

/// ViewModifier que aplica efeito shimmer sobre qualquer view.
/// Usa o sistema de animação SwiftUI — sem CALayer, sem UIKit.
///
/// Uso:
/// ```swift
/// Text("Carregando...")
///     .shimmer(isActive: isLoading)
/// ```
public struct ShimmerModifier: ViewModifier {

    let isActive: Bool

    @State private var phase: CGFloat = -1

    public func body(content: Content) -> some View {
        content
            .overlay(shimmerOverlay.opacity(isActive ? 1 : 0))
            .animation(.easeInOut(duration: 0.3), value: isActive)
            .onAppear { if isActive { animate() } }
            .onChange(of: isActive) { _, active in if active { animate() } }
    }

    // MARK: - Private

    private var shimmerOverlay: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    Color(.systemGray5),
                    Color(.systemGray4),
                    Color(.systemGray5)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 3)
            .offset(x: phase * geo.size.width * 3)
        }
        .clipped()
    }

    private func animate() {
        phase = -1
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }
}

public extension View {
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}
```

**Nota**: o shard que quiser shimmer usa `@State private var isLoading = true` e
aplica `.shimmer(isActive: isLoading)` sobre sua view — sem herdar nada.

**Commit**: `[Phase 4] CaosShimmerModifier — SwiftUI nativo, sem UIView/CAGradientLayer`

---

### Fase 5 — Limpeza, CaosEnvironment e CaosProps

**Objetivo**: finalizar a remoção de todos os rastros UIKit e simplificar APIs.

**`CaosEnvironment.swift`** — remover `CaosCoordinator`, manter `caosStore`:

```swift
import SwiftUI

private struct CaosStoreKey: EnvironmentKey {
    static let defaultValue = CaosStore()
}

public extension EnvironmentValues {
    var caosStore: CaosStore {
        get { self[CaosStoreKey.self] }
        set { self[CaosStoreKey.self] = newValue }
    }
}

public extension View {
    func caosStore(_ store: CaosStore) -> some View {
        environment(\.caosStore, store)
    }
}
```

**`CaosScreen.swift`** — remover props deprecated:
- Deletar `var container: String` (deprecated v0)
- Deletar `var shards: [String]` (deprecated v0)
- `CaosContainer`, `CaosEdgeInsets` permanecem

**`CaosProps.swift`** — remover UIColor:
- Deletar `func color(_:) -> UIColor?`
- Deletar `func swiftUIColor(_:) -> Color?`
- Apps usam `props.string("color")` e convertem com sua própria extensão
- Deletar `extension UIColor { init?(caosHex:) }`
- Deletar o bloco `#if canImport(UIKit)` inteiro

**Resultado**: zero `import UIKit` em qualquer arquivo do `Sources/Caos/`. Zero
`#if canImport(UIKit)`. O `swift build` e `swift test` passam no macOS sem flags.

**Commit**: `[Phase 5] Cleanup — remove deprecated props, UIColor, all #if canImport(UIKit)`

---

### Fase 6 — Testes, SPM e Documentação

**Objetivo**: reescrever os testes para o novo modelo e validar o build cross-platform.

#### Estrutura de testes

```
Tests/CaosTests/
├── Fixtures/
│   ├── valid_v1.yaml
│   └── edge_cases.yaml
├── CaosParserTests.swift       ← sem mudanças
├── CaosStoreTests.swift        ← reescrever (novo registry)
├── CaosScreenViewTests.swift   ← novo (testa parsing + container)
├── CaosShimmerTests.swift      ← reescrever (ShimmerModifier, não UIView)
└── CaosContainerViewTests.swift ← novo (testa VStack/HStack/Grid)
```

**Deletar**:
- `CaosEngineTests.swift` (CaosEngine não existe mais)
- `CaosDataBindingTests.swift` (CaosDataBinding não existe mais)
- `CaosSwiftUITests.swift` (fundir com CaosScreenViewTests)

**Package.swift** — ajustes:
- Remover `Sources/Caos/UI/` das source paths (pasta vazia pode ser deletada)
- `swift test` agora funciona no macOS sem `--sdk iphonesimulator` pois sem UIKit
- Atualizar nightly.yml: restaurar `swift test --enable-code-coverage`

**README.md** — seção de uso atualizada:

```swift
// 1. Crie o store e registre seus shards
let store = CaosStore()
store.register(type: "card", view: CardView.self)
store.register(type: "shortcut", view: ShortcutView.self)

// 2. Injete o store e use CaosScreenView
ContentView()
    .caosStore(store)

// 3. Em qualquer View filha:
CaosScreenView(name: "home")
    .onCaosTap { id, context in
        router.navigate(to: id, context: context)
    }

// 4. Defina um shard:
struct CardView: CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosStore) var store
    @Environment(\.caosTapAction) var onTap

    var body: some View {
        Text(props.string("title") ?? "")
    }
}
```

**Commit**: `[Phase 6] Tests, SPM, README — native SwiftUI migration complete`

---

## Arquivos Finais (pós-migração)

```
Sources/Caos/
├── Core/
│   ├── CaosError.swift              ← sem mudanças
│   └── CaosStore.swift              ← refatorado (factory registry)
├── Schema/
│   ├── CaosParser.swift             ← sem mudanças
│   ├── CaosProps.swift              ← sem UIColor
│   ├── CaosSchema.swift             ← sem mudanças
│   ├── CaosScreen.swift             ← sem deprecated, sem UIEdgeInsets (usa CaosEdgeInsets)
│   └── CaosShard.swift              ← sem mudanças
└── SwiftUI/
    ├── CaosContainerView.swift      ← novo
    ├── CaosEnvironment.swift        ← simplificado
    ├── CaosScreenView.swift         ← reescrito (nativo)
    ├── CaosShimmerModifier.swift    ← novo (substitui CaosShimmerView)
    ├── CaosSwiftUIView.swift        ← reescrito (protocolo principal)
    ├── CaosTapHandler.swift         ← novo
    └── CaosUnknownShardView.swift   ← novo

Sources/CaosLint/
    └── main.swift                   ← sem mudanças

(Pasta Sources/Caos/UI/ deletada inteiramente)
```

**Resultado**: zero `import UIKit`, zero `#if canImport(UIKit)`, zero `UIViewRepresentable`.
O framework é 100% SwiftUI + Swift stdlib + Combine.

---

## Critérios de Aceite

- [ ] `swift build` passa no macOS sem flags adicionais
- [ ] `swift test` passa no macOS sem `--sdk iphonesimulator`
- [ ] `swiftlint --strict` passa sem violações
- [ ] `swiftformat Sources Tests --lint` passa sem erros
- [ ] Nenhum `import UIKit` em `Sources/Caos/`
- [ ] Nenhum `#if canImport(UIKit)` em `Sources/Caos/`
- [ ] Nenhum `UIViewRepresentable` em `Sources/Caos/`
- [ ] Cobertura de testes ≥ 80%
- [ ] Example app compila e renderiza tela via YAML v1

---

## Dependências entre Fases

```
Fase 0 (delete UIKit layer)
    ↓
Fase 1 (CaosStore factory registry)
    ↓
Fase 2 (CaosSwiftUIView + CaosTapHandler)   ←─ pode ser paralela com Fase 1
    ↓
Fase 3 (CaosContainerView + CaosScreenView)  ←─ depende de Fase 1 e 2
    │
Fase 4 (ShimmerModifier)                     ←─ pode ser paralela com Fase 3
    ↓
Fase 5 (Cleanup final)
    ↓
Fase 6 (Testes + SPM + Docs)
```
