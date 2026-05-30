# Caos Framework — Plano de Evolução iOS

## Visão Geral

Evolução do framework Caos para iOS em 6 fases (incluindo Fase 0 de preparação), cobrindo
schema YAML rico e versionado, propriedades visuais configuráveis, data binding reativo,
suporte nativo a SwiftUI com arquitetura **MV (Model-View)** e distribuição production-ready.

O desenvolvimento é conduzido com **multi-agentes paralelos** onde possível, cada agente com
escopo isolado de arquivos e responsabilidade única. A integração ocorre via Pull Requests com
CI/CD obrigatório antes de merge.

---

## Estado Atual (Baseline v0)

Documentação do estado real do projeto antes de qualquer evolução. Agentes devem usar esta
seção como ponto de partida para entender o que existe e o que precisa ser criado ou modificado.

### Arquivos de Núcleo (existentes)

| Arquivo | Estado | Observação |
|---|---|---|
| `Caos/Classes/Caos.swift` | Funcional | Entry point; lê YAML do bundle e cria `CaosEngine` |
| `CaosEngine.swift` | Funcional | Instancia views via `NSClassFromString` — acoplado ao nome do módulo |
| `CaosEngineDelegate.swift` | Funcional | Protocolo com `didTapCardView(context: String)` e `requestDataForLabel()` |
| `CaosParser.swift` | Limitado | Parser linha-a-linha simples; não é YAML real |
| `CaosScreen.swift` | Limitado | Só `container: String` e `shards: [String]` |
| `CaosView.swift` | Mínimo | Protocolo sem `configure(with:)` |

### Arquivos a Criar (não existem)

`CaosSchema.swift`, `CaosProps.swift`, `CaosStore.swift`, `CaosDataBinding.swift`,
`CaosScreenView.swift`, `CaosEnvironment.swift`, `Package.swift`, testes reais,
fixtures YAML, workflows GitHub Actions.

### Problemas Conhecidos no Baseline

1. **YAML v0 inválido**: o formato atual usa indentação irregular e não é YAML-padrão:
   ```yaml
   # v0 — formato atual (inválido como YAML real)
   container_type: list_vertical
       shard: Caos_Example.CaosViewCard
       shard: Caos_Example.CaosViewShortcuts
   ```
   A migração para v1 é uma quebra completa de compatibilidade.

2. **Acoplamento de módulo no YAML**: shards são referenciados pelo nome completo da classe
   (`Caos_Example.CaosViewCard`). Renomear o módulo quebra todos os arquivos YAML.

3. **`CaosViewShortcutsChainShimmer`**: componente existente que é cópia idêntica de
   `CaosViewShortcutsChain` sem nenhum efeito de shimmer implementado. Deve ser substituído
   por uma implementação de skeleton/shimmer real na Fase 2.

4. **Testes inexistentes**: `Tests/Tests.swift` contém apenas `XCTAssert(true)`.

5. **CI obsoleto**: `.travis.yml` usa Xcode 7.3 e simulador iOS 9.3 — será removido na Fase 0.

6. **Deployment target defasado**: Podspec e Podfile declaram `iOS 10.0`. O plano requer
   iOS 16 (para SwiftUI estável + Combine + NavigationStack).

7. **`randomizeUIColor()` em `CaosEngine`**: método privado nunca exposto, será removido
   junto com a limpeza do engine na Fase 2.

---

## Arquitetura SwiftUI — Padrão MV

Toda implementação SwiftUI do Caos segue o padrão **Model-View (MV)**, rejeitando MVVM por
ser desnecessariamente verboso no ecossistema SwiftUI.

### Princípios

| Princípio | Regra |
|---|---|
| **Model é a única fonte de verdade** | `CaosStore` é `@Observable` e carrega todo estado de dados |
| **Views são projeções puras** | Views lêem do Model; nunca possuem estado de negócio |
| **Sem ViewModel** | Não há classes intermediárias entre View e Model |
| **DI via `@Environment`** | `CaosStore` é injetado na árvore de views via `@Environment` |
| **`@State` só para UI efêmero** | Foco, animação local, texto de campo — nunca dados de domínio |
| **Ações diretas no Model** | `view → store.action()` sem intermediário |
| **Navegação via `NavigationStack`** | Sem Coordinator; rotas são valores (`enum`) no Model |

### Estrutura de Camadas

```
┌─────────────────────────────────────────────────┐
│                  VIEW LAYER                      │
│  CaosScreenView  ·  CaosShardView  ·  Shard*    │
│         ↓ lê                  ↑ nenhum estado   │
│         └──── @Environment(\.caosStore) ─────┐  │
├─────────────────────────────────────────────────┤
│                  MODEL LAYER                     │
│  CaosStore (@Observable)                        │
│    ├── providers: [String: () -> Any]           │
│    ├── publishers: [String: AnyPublisher]       │
│    └── shardRegistry: [String: CaosView.Type]   │
├─────────────────────────────────────────────────┤
│                  SCHEMA LAYER                    │
│  CaosParser  ·  CaosSchema  ·  CaosProps        │
└─────────────────────────────────────────────────┘
```

### Contrato do Model (`CaosStore`)

```swift
@Observable
public final class CaosStore {

    // Registro de dados
    public func register<T>(key: String, provider: @escaping () -> T)
    public func register<T>(key: String, publisher: AnyPublisher<T, Never>)

    // Registro de tipos de shard (substitui NSClassFromString)
    public func register(type: String, view: any CaosView.Type)

    // Resolução
    public func resolve<T>(key: String) -> T?
    public func publisher<T>(for key: String) -> AnyPublisher<T, Never>?
    internal func viewType(for type: String) -> (any CaosView.Type)?
}
```

### Contrato de Shard MV-compatível

```swift
// UIKit shard
public protocol CaosView: UIView {
    var store: CaosStore? { get set }
    func configure(with props: CaosProps)
}

// SwiftUI shard
public protocol CaosSwiftUIView: View {
    init(props: CaosProps)
    // acessa store via @Environment(\.caosStore)
}
```

### Uso correto — View não tem lógica

```swift
// CERTO — View é projeção pura
struct BalanceShardView: View, CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosStore) private var store

    var body: some View {
        Text(store.resolve(key: props.string("dataKey") ?? "") ?? "--")
            .foregroundStyle(props.color("textColor") ?? .primary)
    }
}

// ERRADO — ViewModel desnecessário
class BalanceViewModel: ObservableObject { ... } // não fazer
```

### Compatibilidade iOS

| Feature | iOS mínimo |
|---|---|
| Framework core (UIKit) | iOS 16 |
| SwiftUI module | iOS 16 |
| `@Observable` macro (otimização) | iOS 17 — adotado internamente quando disponível |
| `NavigationStack` | iOS 16 |
| Combine | iOS 13 (já disponível) |

---

## Estratégia Multi-Agente

### Princípios

- Cada agente trabalha em uma **branch de feature isolada**
- Agentes não compartilham arquivos em paralelo (evita conflitos)
- Um agente de **integração/review** valida cada PR antes do merge
- O agente de **CI/CD** é autônomo e reage a eventos do GitHub

### Mapa de Agentes por Fase

```
Fase 0 (Preparação)
└── Agent-Setup        → remover Travis, criar develop, corrigir Podspec/Podfile

Fase 1 (Schema)
└── Agent-Schema       → CaosParser, CaosSchema, CaosScreen, CaosProps,
                         mecanismo de registro de tipos, fixtures YAML, guia migração v0→v1

Fase 2 (Props Visuais)
├── Agent-Props        → CaosView.configure(with:), CaosEngine refactor, shimmer real
└── Agent-PropsTests   → CaosPropsTests, CaosEngineTests

Fase 3 (Data Binding)
├── Agent-Store        → CaosStore (@Observable), CaosDataBinding
├── Agent-StoreTests   → CaosStoreTests, CaosDataBindingTests
└── Agent-Migration    → deprecar delegate, guia de migração da API

Fase 4 (SwiftUI MV)
├── Agent-SwiftUI      → CaosScreenView, CaosSwiftUIView, CaosEnvironment (MV)
└── Agent-SwiftUITests → testes de integração SwiftUI

Fase 5 (Distribuição)
├── Agent-SPM          → Package.swift, estrutura Sources/Tests
├── Agent-Docs         → README reestruturado, CHANGELOG, guia migração v0→v1
└── Agent-CI           → workflows GitHub Actions, remoção definitiva do Travis
```

### Fluxo de Trabalho Multi-Agente

```
main
 └── develop
      ├── feature/phase-0-setup           ← Agent-Setup
      ├── feature/phase-1-schema          ← Agent-Schema
      ├── feature/phase-2-props           ← Agent-Props + Agent-PropsTests
      ├── feature/phase-3-store           ← Agent-Store + Agent-StoreTests
      ├── feature/phase-4-swiftui         ← Agent-SwiftUI + Agent-SwiftUITests
      └── feature/phase-5-distribution   ← Agent-SPM + Agent-Docs + Agent-CI
```

Cada feature branch é mergeada em `develop` após:
1. CI verde (lint + testes + cobertura ≥ 90%)
2. Review do agente de integração
3. Aprovação manual do owner

> **Pré-requisito:** a branch `develop` ainda não existe no repositório. Deve ser criada
> manualmente ou pelo Agent-Setup antes de qualquer outra fase iniciar.

---

## Fase 0 — Preparação do Repositório

**Branch:** `feature/phase-0-setup`
**Agente responsável:** `Agent-Setup`

### Objetivo

Estabilizar o repositório antes de qualquer implementação: limpar CI legado, corrigir
deployment target e criar a estrutura de branches.

### Tarefas

| Tarefa | Arquivo | Ação |
|---|---|---|
| Remover Travis CI | `.travis.yml` | Deletar |
| Corrigir deployment target | `Caos.podspec` | `s.ios.deployment_target = '16.0'` |
| Corrigir deployment target | `Example/Podfile` | `platform :ios, '16.0'` |
| Atualizar versão do pod | `Caos.podspec` | `s.version = '1.0.0'` |
| Criar branch develop | git | `git checkout -b develop && git push -u origin develop` |
| Stub de Package.swift | `Package.swift` | Criar esqueleto vazio para SPM reconhecer o repo |

### Critérios de Aceite

- [ ] `.travis.yml` removido do repositório
- [ ] Podspec e Podfile com `ios '16.0'`
- [ ] Branch `develop` existe no remoto
- [ ] `Package.swift` stub presente (build pode falhar, será completado na Fase 5)

---

## Fase 1 — Schema YAML Rico e Versionado

**Branch:** `feature/phase-1-schema`
**Agente responsável:** `Agent-Schema`

### Objetivo

Definir o schema YAML v1 hierárquico e versionado, reescrever o `CaosParser` para suportá-lo,
introduzir o mecanismo de registro de tipos de shard (eliminando `NSClassFromString`) e
documentar a migração do formato v0.

### Schema YAML v1

```yaml
version: 1
screens:
  - id: home
    container:
      type: vertical          # vertical | horizontal | grid
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
          textColor: "#1A1A1A"
          elevation: 4
      - type: ShortcutsChain
        id: shortcuts
        props:
          items:
            - label: "Pix"
              icon: "arrow.left.arrow.right.circle"
              action: "pix"
            - label: "Simulador"
              icon: "iphone.gen3.circle"
              action: "simulator"
```

### Mecanismo de Registro de Tipos (substitui `NSClassFromString`)

O campo `type` no YAML é resolvido pelo `CaosStore` via um registro explícito feito pelo app,
eliminando o acoplamento ao nome do módulo Swift.

```swift
// No app, antes de carregar qualquer YAML
store.register(type: "CardView",       view: CaosViewCard.self)
store.register(type: "ShortcutsChain", view: CaosViewShortcutsChain.self)
store.register(type: "BannerView",     view: CaosViewBanner.self)

// CaosEngine resolve internamente
guard let viewType = store.viewType(for: shard.type) else {
    print("Caos: tipo '\(shard.type)' não registrado")
    return
}
let view = viewType.init()
```

### Guia de Migração YAML v0 → v1

```yaml
# ANTES (v0) — inválido como YAML padrão, acoplado ao módulo Swift
container_type: list_vertical
    shard: Caos_Example.CaosViewCard
    shard: Caos_Example.CaosViewShortcuts

# DEPOIS (v1) — YAML padrão, desacoplado do módulo
version: 1
screens:
  - id: home
    container:
      type: vertical
      spacing: 8
    shards:
      - type: CardView
        id: card_1
        props: {}
      - type: Shortcuts
        id: shortcuts_1
        props: {}
```

**Passos de migração para apps consumidores:**
1. Substituir o arquivo `.yaml` pelo novo formato v1
2. Registrar cada tipo de shard no `CaosStore` antes de carregar o YAML
3. Remover referências ao nome do módulo nos YAMLs

### Contrato de `CaosProps`

```swift
public struct CaosProps: Sendable {
    private let data: [String: Any]

    public init(_ data: [String: Any]) { self.data = data }

    public func string(_ key: String) -> String?
    public func int(_ key: String) -> Int?
    public func double(_ key: String) -> Double?
    public func bool(_ key: String) -> Bool?
    public func color(_ key: String) -> UIColor?      // parse "#RRGGBB" e "#AARRGGBB"
    public func color(_ key: String) -> Color?        // SwiftUI overload
    public func nested(_ key: String) -> CaosProps?
    public func array(_ key: String) -> [CaosProps]?
}
```

### Arquivos Afetados

| Arquivo | Ação |
|---|---|
| `CaosParser.swift` | Reescrita completa — parser YAML hierárquico stdlib-only |
| `CaosSchema.swift` | Novo — modelo de schema versionado com `version`, `screens` |
| `CaosScreen.swift` | Adicionar `id`, `padding`, `spacing`, `shards: [CaosShard]` |
| `CaosShard.swift` | Novo — modelo de shard com `type`, `id`, `props: CaosProps` |
| `CaosProps.swift` | Novo — dicionário tipado de propriedades |
| `Tests/CaosParserTests.swift` | Novo — testes unitários do parser |
| `Tests/Fixtures/valid_v1.yaml` | Novo — YAML v1 válido completo |
| `Tests/Fixtures/invalid_no_version.yaml` | Novo — YAML sem campo version |
| `Tests/Fixtures/edge_cases.yaml` | Novo — screens vazias, props aninhadas, tipos desconhecidos |
| `Docs/Migration_v0_to_v1.md` | Novo — guia de migração do formato YAML |

### Critérios de Aceite

- [ ] Parser lê YAML v1 sem dependência de terceiros (stdlib only)
- [ ] Parser rejeita YAML sem `version` com erro descritivo (`CaosError.missingVersion`)
- [ ] `CaosProps.color()` converte hex 6 e 8 dígitos (UIColor e Color)
- [ ] `CaosProps.array()` retorna lista de `CaosProps` aninhados
- [ ] Cobertura de testes ≥ 90% nos novos arquivos
- [ ] Fixtures de YAML válido, inválido e edge cases presentes
- [ ] `NSClassFromString` removido de `CaosEngine`
- [ ] Guia de migração v0→v1 presente em `Docs/`

---

## Fase 2 — Propriedades Visuais e Componentes

**Branch:** `feature/phase-2-props`
**Agentes responsáveis:** `Agent-Props`, `Agent-PropsTests`

### Objetivo

O engine passa `CaosProps` para cada shard na inicialização, eliminando hardcode visual.
O `CaosViewShortcutsChainShimmer` é reimplementado como estado de carregamento real.

### Mudança no Protocolo `CaosView`

```swift
public protocol CaosView: UIView {
    var store: CaosStore? { get set }
    func configure(with props: CaosProps)
    func showLoading()   // exibe skeleton/shimmer
    func hideLoading()   // remove skeleton/shimmer
}

// Extensão com implementação padrão para não quebrar shards existentes
public extension CaosView {
    func showLoading() {}
    func hideLoading() {}
}
```

### Shimmer — Reimplementação do `CaosViewShortcutsChainShimmer`

O arquivo atual `CaosViewShortcutsChainShimmer.swift` é uma cópia idêntica de
`CaosViewShortcutsChain.swift` sem nenhum efeito de shimmer. Deve ser **deletado e
recriado** com uma implementação real baseada em `CAGradientLayer`.

```swift
// Mecanismo de shimmer genérico — reutilizável em qualquer CaosView
public final class CaosShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()

    public func startShimmer()
    public func stopShimmer()
}
```

Shards com estado de carregamento usam composição:

```swift
public class CaosViewShortcutsChain: UIView, CaosView {
    private let shimmer = CaosShimmerView()

    public func showLoading() { shimmer.startShimmer() }
    public func hideLoading() { shimmer.stopShimmer() }
}
```

### Mudança no `CaosEngine`

```swift
// Antes — sem props, sem shimmer
let shardViewInstance = classType.init()

// Depois — props e store injetados
let shardViewInstance = classType.init()
shardViewInstance.store = store
shardViewInstance.configure(with: shard.props)
```

### Arquivos Afetados

| Arquivo | Ação |
|---|---|
| `CaosView.swift` | Adicionar `configure(with:)`, `showLoading()`, `hideLoading()` |
| `CaosEngine.swift` | Passar `props` e `store`; remover `randomizeUIColor()` |
| `CaosShimmerView.swift` | Novo — componente genérico de shimmer |
| `Example/CaosViewShortcutsChainShimmer.swift` | Deletar e recriar com shimmer real |
| `Example/ViewController.swift` | Atualizar para schema v1 + registro de tipos |
| `Example/caos.yaml` | Atualizar para formato v1 |
| `Tests/CaosEngineTests.swift` | Novo — testes de configure e passagem de props |
| `Tests/CaosShimmerTests.swift` | Novo — testes de showLoading/hideLoading |

### Critérios de Aceite

- [ ] `configure(with:)` é chamado para todo shard instanciado
- [ ] `CaosViewCard` renderiza `backgroundColor`, `cornerRadius`, `textColor` via props
- [ ] `CaosViewShortcutsChainShimmer` exibe gradiente animado real
- [ ] `showLoading()`/`hideLoading()` funcionam em todos os shards de exemplo
- [ ] `randomizeUIColor()` removido do engine
- [ ] Cobertura ≥ 90%

---

## Fase 3 — Sistema de Data Binding (CaosStore como Model)

**Branch:** `feature/phase-3-store`
**Agentes responsáveis:** `Agent-Store`, `Agent-StoreTests`, `Agent-Migration`

### Objetivo

Implementar o `CaosStore` como o **Model central** do padrão MV, com suporte a dados
síncronos e reativos via Combine. O delegate manual de dados é depreciado.

### `CaosStore` — Implementação Completa

```swift
@Observable
public final class CaosStore {

    // MARK: - Internal state (não exposto diretamente — views lêem via resolve/publisher)
    private var providers: [String: () -> Any] = [:]
    private var publishers: [String: AnyPublisher<Any, Never>] = [:]
    private var shardRegistry: [String: any CaosView.Type] = [:]
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    // MARK: - Registro de dados

    public func register<T>(key: String, provider: @escaping () -> T) {
        providers[key] = { provider() }
    }

    public func register<T>(key: String, publisher: AnyPublisher<T, Never>) {
        publishers[key] = publisher.map { $0 as Any }.eraseToAnyPublisher()
    }

    // MARK: - Registro de tipos de shard

    public func register(type: String, view: any CaosView.Type) {
        shardRegistry[type] = view
    }

    // MARK: - Resolução

    public func resolve<T>(key: String) -> T? {
        return providers[key]?() as? T
    }

    public func publisher<T>(for key: String) -> AnyPublisher<T, Never>? {
        return publishers[key]?.compactMap { $0 as? T }.eraseToAnyPublisher()
    }

    internal func viewType(for type: String) -> (any CaosView.Type)? {
        return shardRegistry[type]
    }
}
```

### Uso no YAML

```yaml
shards:
  - type: BalanceCard
    id: balance
    props:
      dataKey: "user.balance"
      textColor: "#1A1A1A"
```

### Uso no App (MV correto)

```swift
// No app — registro no Model antes de carregar a tela
let store = CaosStore()
store.register(key: "user.balance") { UserSession.current.formattedBalance }

// Reativo — shard atualiza automaticamente quando publisher emite
store.register(
    key: "user.balance",
    publisher: UserSession.shared.$balance
        .map { $0.formatted(.currency(code: "BRL")) }
        .eraseToAnyPublisher()
)
```

### Shard consumindo o store (MV)

```swift
// UIKit shard — acessa store injetado pelo engine
public class BalanceCardView: UIView, CaosView {
    public var store: CaosStore?
    private var cancellable: AnyCancellable?

    public func configure(with props: CaosProps) {
        guard let key = props.string("dataKey"), let store else { return }

        // Resolução síncrona inicial
        valueLabel.text = store.resolve(key: key)

        // Subscrição reativa
        cancellable = store.publisher(for: key)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in self?.valueLabel.text = value }
    }
}
```

### Deprecação do Delegate

```swift
public protocol CaosEngineDelegate: AnyObject {
    var rootView: UIView { get }

    // Renomeado — context agora é [String: Any] para suportar múltiplos valores
    func didTapShard(id: String, context: [String: Any])

    // DEPRECATED — migrar para CaosStore.register(key:provider:)
    @available(*, deprecated, renamed: "CaosStore.register(key:provider:)")
    func requestDataForLabel() -> String

    // DEPRECATED — migrar para didTapShard(id:context:)
    @available(*, deprecated, renamed: "didTapShard(id:context:)")
    func didTapCardView(context: String)
}
```

### Arquivos Afetados

| Arquivo | Ação |
|---|---|
| `CaosStore.swift` | Novo — Model central `@Observable` |
| `CaosDataBinding.swift` | Novo — resolve `dataKey` dos props nos shards |
| `CaosEngineDelegate.swift` | Deprecar `requestDataForLabel()` e `didTapCardView` |
| `CaosEngine.swift` | Receber `CaosStore` no init; injetar em cada shard |
| `Caos.swift` | Sobrecarga de `configure` aceitando `CaosStore` |
| `Tests/CaosStoreTests.swift` | Novo |
| `Tests/CaosDataBindingTests.swift` | Novo |
| `Docs/Migration_Delegate_to_Store.md` | Novo — guia de migração do delegate para o store |

### Critérios de Aceite

- [ ] `CaosStore` resolve valores síncronos e reativos
- [ ] Shard com `dataKey` atualiza automaticamente via Combine quando o publisher emite
- [ ] `requestDataForLabel()` e `didTapCardView(context:)` emitem warnings de deprecação
- [ ] `didTapShard(id:context:)` entrega o `id` do shard e o contexto tipado
- [ ] `CaosStore` é thread-safe para leituras concorrentes
- [ ] Cobertura ≥ 90%

---

## Fase 4 — Suporte Nativo a SwiftUI com Arquitetura MV

**Branch:** `feature/phase-4-swiftui`
**Agentes responsáveis:** `Agent-SwiftUI`, `Agent-SwiftUITests`

### Objetivo

Expor o framework como API SwiftUI nativa seguindo estritamente o padrão MV:
sem ViewModels, sem UIViewRepresentable manual pelo usuário, store injetado via `@Environment`.

### API Pública

```swift
// Uso simples — store padrão criado internamente
struct HomeView: View {
    var body: some View {
        CaosScreenView(name: "home", bundle: .main)
    }
}

// Uso com store externo — padrão MV correto
struct HomeView: View {
    @State private var store = CaosStore()   // @State porque CaosStore é @Observable

    var body: some View {
        CaosScreenView(name: "home", bundle: .main)
            .caosStore(store)
            .onAppear {
                store.register(key: "user.balance") { UserSession.current.balance }
                store.register(type: "CardView", view: CaosViewCard.self)
            }
    }
}
```

### `CaosScreenView` — Implementação Interna

```swift
public struct CaosScreenView: UIViewRepresentable {
    let name: String
    let bundle: Bundle

    @Environment(\.caosStore) private var store

    public func makeUIView(context: Context) -> UIScrollView {
        guard let engine = Caos.configure(
            bundle: bundle,
            name: name,
            store: store,
            delegate: context.coordinator
        ) else {
            return UIScrollView()
        }
        return engine.getScreenByIndex(index: 0) as? UIScrollView ?? UIScrollView()
    }

    public func updateUIView(_ uiView: UIScrollView, context: Context) {}

    public func makeCoordinator() -> CaosCoordinator {
        CaosCoordinator(store: store)
    }
}
```

### `CaosCoordinator` — Bridge UIKit→SwiftUI sem ViewModel

```swift
public final class CaosCoordinator: NSObject, CaosEngineDelegate {
    private let store: CaosStore

    init(store: CaosStore) { self.store = store }

    public var rootView: UIView { UIView() }

    public func didTapShard(id: String, context: [String: Any]) {
        store.handleTap(shardId: id, context: context)
    }
}
```

### Protocolo para Shards SwiftUI Puros

```swift
// Shards SwiftUI recebem props e acessam store via @Environment — MV puro
public protocol CaosSwiftUIView: View {
    init(props: CaosProps)
}

// Exemplo de shard SwiftUI correto
struct BalanceCardView: View, CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosStore) private var store

    var body: some View {
        VStack(alignment: .leading) {
            Text(props.string("title") ?? "")
                .font(.headline)
            Text(store.resolve(key: props.string("dataKey") ?? "") ?? "--")
                .font(.title2.bold())
                .foregroundStyle(props.color("textColor") ?? Color.primary)
        }
        .padding(props.double("padding").map { CGFloat($0) } ?? 16)
        .background(props.color("backgroundColor") ?? Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: props.double("cornerRadius").map { CGFloat($0) } ?? 12))
    }
}
```

### `CaosEnvironmentKey`

```swift
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

### Exemplo de App SwiftUI Completo (sem UIKit manual)

```swift
@main
struct CaosApp: App {
    @State private var store = CaosStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CaosScreenView(name: "home", bundle: .main)
                    .caosStore(store)
                    .navigationTitle("Home")
            }
            .caosStore(store)
        }
    }

    init() {
        store.register(type: "CardView",       view: CaosViewCard.self)
        store.register(type: "ShortcutsChain", view: CaosViewShortcutsChain.self)
        store.register(key: "user.balance",    provider: { UserSession.current.balance })
    }
}
```

### Arquivos Afetados

| Arquivo | Ação |
|---|---|
| `CaosScreenView.swift` | Novo — UIViewRepresentable wrapper |
| `CaosSwiftUIView.swift` | Novo — protocolo para shards SwiftUI puros |
| `CaosEnvironment.swift` | Novo — EnvironmentKey + `.caosStore()` modifier |
| `CaosCoordinator.swift` | Novo — bridge UIKit→SwiftUI sem ViewModel |
| `Caos.swift` | Sobrecarga de `configure` aceitando `CaosStore` sem delegate |
| `Example/ContentView.swift` | Novo — app de exemplo 100% SwiftUI |
| `Tests/CaosSwiftUITests.swift` | Novo — testes com ViewInspector |
| `Tests/CaosEnvironmentTests.swift` | Novo — testes de injeção via @Environment |

### Critérios de Aceite

- [ ] `CaosScreenView` renderiza corretamente no Xcode Preview
- [ ] `@Environment(\.caosStore)` é recebido corretamente por shards SwiftUI
- [ ] `CaosStore` injetado via `.caosStore()` é acessível em toda a hierarquia de views
- [ ] Nenhum ViewModel criado — toda lógica fica no `CaosStore` (Model)
- [ ] App de exemplo funciona 100% com SwiftUI sem `UIViewRepresentable` manual
- [ ] Cobertura ≥ 90%

---

## Fase 5 — Distribuição e Developer Experience

**Branch:** `feature/phase-5-distribution`
**Agentes responsáveis:** `Agent-SPM`, `Agent-Docs`, `Agent-CI`

### Objetivos

- Suporte completo a Swift Package Manager (padrão moderno)
- Manter suporte a CocoaPods para retrocompatibilidade
- Documentação completa com README reestruturado
- Validador de YAML via CLI (`caos-lint`)
- GitHub Actions substituindo Travis CI definitivamente

### `Package.swift`

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Caos",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Caos", targets: ["Caos"]),
        .executable(name: "caos-lint", targets: ["CaosLint"]),
    ],
    targets: [
        .target(
            name: "Caos",
            path: "Sources/Caos",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .executableTarget(
            name: "CaosLint",
            dependencies: ["Caos"],
            path: "Sources/CaosLint"
        ),
        .testTarget(
            name: "CaosTests",
            dependencies: ["Caos"],
            path: "Tests/CaosTests",
            resources: [.copy("Fixtures")]
        ),
    ]
)
```

### Podspec Atualizado

```ruby
Pod::Spec.new do |s|
  s.name             = 'Caos'
  s.version          = '1.0.0'
  s.summary          = 'Server-Driven UI framework for iOS — build screens from YAML.'
  s.description      = <<-DESC
    Caos (Configurable Automated On-demand Screens) generates iOS UI screens
    dynamically from YAML files. Supports SwiftUI and UIKit with a reactive
    data binding system and MV architecture.
  DESC
  s.homepage         = 'https://github.com/andersontizaias/Caos'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'andersontizaias' => 'andersontizaias@gmail.com' }
  s.source           = { :git => 'https://github.com/andersontizaias/Caos.git', :tag => s.version.to_s }
  s.ios.deployment_target = '16.0'
  s.swift_version = '5.9'
  s.source_files = 'Sources/Caos/**/*'
end
```

### CLI `caos-lint`

```bash
# Valida o schema do YAML
$ swift run caos-lint caos.yaml
✓ version: 1
✓ screens: 2 found
✓ shards: 5 found
⚠ shard 'BannerView' — prop 'height' missing (expected by type)
✗ shard 'CardView' — id duplicado 'card_1'

Exit code 1 (erros encontrados)
```

### Reestruturação do `README.md`

O README atual é um placeholder gerado pelo CocoaPods com seções vazias. Deve ser
completamente reescrito com a seguinte estrutura:

```
README.md
├── Badges (CI, CocoaPods, SPM, cobertura, iOS, licença)
├── Logo + nome + tagline
├── O que é o Caos (2 parágrafos — problema que resolve)
├── Diagrama de arquitetura (texto ASCII)
├── Quick Start (5 passos, < 20 linhas de código)
├── YAML Schema Reference (tabela de campos + exemplo completo)
├── Registro de Shards
│   ├── UIKit shard
│   └── SwiftUI shard
├── Uso com SwiftUI (exemplo completo com CaosScreenView)
├── Uso com UIKit (exemplo completo com ViewController)
├── Data Binding com CaosStore
│   ├── Registro síncrono
│   └── Registro reativo (Combine)
├── Criando Shards Customizados
│   ├── UIKit (protocolo CaosView)
│   └── SwiftUI (protocolo CaosSwiftUIView)
├── caos-lint (validação local do YAML)
├── Migração v0 → v1 (link para Docs/Migration_v0_to_v1.md)
├── Requisitos (iOS 16+, Xcode 16+, Swift 5.9+)
├── Instalação
│   ├── Swift Package Manager
│   └── CocoaPods
├── Contribuindo (link para CONTRIBUTING.md)
└── Licença
```

**Badges obrigatórios no topo:**
```markdown
[![CI](https://github.com/andersontizaias/Caos/actions/workflows/ci.yml/badge.svg)](...)
[![CocoaPods](https://img.shields.io/cocoapods/v/Caos.svg)](...)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)](...)
[![Coverage](https://codecov.io/gh/andersontizaias/Caos/branch/main/graph/badge.svg)](...)
[![iOS](https://img.shields.io/badge/iOS-16%2B-blue)](...)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](...)
```

### Estrutura de Diretórios Final (SPM-compatible)

```
Caos/
├── Sources/
│   ├── Caos/
│   │   ├── Core/
│   │   │   ├── Caos.swift
│   │   │   ├── CaosEngine.swift
│   │   │   ├── CaosStore.swift
│   │   │   └── CaosDataBinding.swift
│   │   ├── Schema/
│   │   │   ├── CaosParser.swift
│   │   │   ├── CaosSchema.swift
│   │   │   ├── CaosScreen.swift
│   │   │   ├── CaosShard.swift
│   │   │   └── CaosProps.swift
│   │   ├── UI/
│   │   │   ├── CaosView.swift
│   │   │   ├── CaosShimmerView.swift
│   │   │   └── CaosEngineDelegate.swift
│   │   └── SwiftUI/
│   │       ├── CaosScreenView.swift
│   │       ├── CaosSwiftUIView.swift
│   │       ├── CaosCoordinator.swift
│   │       └── CaosEnvironment.swift
│   └── CaosLint/
│       └── main.swift
├── Tests/
│   └── CaosTests/
│       ├── Fixtures/
│       │   ├── valid_v1.yaml
│       │   ├── invalid_no_version.yaml
│       │   └── edge_cases.yaml
│       ├── CaosParserTests.swift
│       ├── CaosPropsTests.swift
│       ├── CaosEngineTests.swift
│       ├── CaosStoreTests.swift
│       ├── CaosDataBindingTests.swift
│       └── CaosSwiftUITests.swift
├── Example/
│   └── Caos/
│       ├── ContentView.swift          ← SwiftUI
│       └── ViewController.swift      ← UIKit (compatibilidade)
├── Docs/
│   ├── Migration_v0_to_v1.md
│   └── Migration_Delegate_to_Store.md
├── scripts/
│   └── check_coverage.py
├── Package.swift
├── Caos.podspec
├── README.md
├── CHANGELOG.md
└── CONTRIBUTING.md
```

### Entregas

- [ ] `.travis.yml` removido (se não feito na Fase 0)
- [ ] `Package.swift` funcional com SPM (build + test)
- [ ] Podspec atualizado para v1.0.0 com iOS 16
- [ ] Estrutura `Sources/` reorganizada por módulo
- [ ] README completamente reescrito conforme spec acima
- [ ] `CHANGELOG.md` com histórico v0.1.0 → v1.0.0
- [ ] `CONTRIBUTING.md` com guia de contribuição
- [ ] `Docs/Migration_v0_to_v1.md` completo
- [ ] `Docs/Migration_Delegate_to_Store.md` completo
- [ ] CLI `caos-lint` como executable target funcional

---

## Pipeline CI/CD — GitHub Actions

### Visão Geral dos Workflows

```
.github/
└── workflows/
    ├── ci.yml              ← roda em todo PR para develop/main
    ├── release.yml         ← roda ao criar tag vX.Y.Z
    ├── lint.yml            ← roda em todo push (feedback rápido)
    └── nightly.yml         ← roda todo dia às 02:00 UTC
```

---

### `lint.yml` — Feedback Rápido (< 2 min)

**Gatilho:** todo `push` em qualquer branch

```yaml
name: Lint

on: [push]

jobs:
  swiftlint:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Cache SwiftLint
        uses: actions/cache@v4
        with:
          path: ~/.swiftlint
          key: swiftlint-${{ runner.os }}
      - name: SwiftLint
        run: swiftlint --strict --reporter github-actions-logging

  swiftformat:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: SwiftFormat (check only)
        run: swiftformat --lint Sources Tests
```

**`.swiftlint.yml` recomendado:**
```yaml
disabled_rules:
  - todo
opt_in_rules:
  - empty_count
  - explicit_init
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
line_length: 120
```

---

### `ci.yml` — Validação Completa de PR

**Gatilho:** `pull_request` para `develop` ou `main`

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build-and-test:
    runs-on: macos-15
    strategy:
      matrix:
        destination:
          - "platform=iOS Simulator,name=iPhone 16,OS=18.0"
          - "platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.0"

    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_16.app

      - name: Cache SPM
        uses: actions/cache@v4
        with:
          path: .build
          key: spm-${{ runner.os }}-${{ hashFiles('Package.resolved') }}
          restore-keys: spm-${{ runner.os }}-

      - name: Resolve Dependencies
        run: swift package resolve

      - name: Build
        run: |
          xcodebuild build-for-testing \
            -scheme Caos \
            -destination "${{ matrix.destination }}" \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
            | xcpretty

      - name: Test + Coverage
        run: |
          xcodebuild test \
            -scheme Caos \
            -destination "${{ matrix.destination }}" \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults.xcresult \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
            | xcpretty

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-${{ matrix.destination }}
          path: TestResults.xcresult

  coverage:
    runs-on: macos-15
    needs: build-and-test
    steps:
      - uses: actions/checkout@v4

      - name: Download Test Results
        uses: actions/download-artifact@v4
        with:
          name: test-results-platform=iOS Simulator,name=iPhone 16,OS=18.0

      - name: Extract Coverage
        run: |
          xcrun xccov view --report --json TestResults.xcresult > coverage.json

      - name: Check Coverage Threshold (90%)
        run: |
          python3 scripts/check_coverage.py coverage.json 90

      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: coverage.json

  danger:
    runs-on: macos-15
    needs: build-and-test
    steps:
      - uses: actions/checkout@v4
      - name: Danger
        run: bundle exec danger
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**`scripts/check_coverage.py`:**
```python
import json, sys

report = json.load(open(sys.argv[1]))
threshold = float(sys.argv[2])
coverage = report["lineCoverage"] * 100

print(f"Coverage: {coverage:.1f}% (threshold: {threshold}%)")

if coverage < threshold:
    print(f"FAIL: coverage {coverage:.1f}% is below {threshold}%")
    sys.exit(1)

print("PASS")
```

---

### `release.yml` — Release Automático

**Gatilho:** push de tag `v*.*.*`

```yaml
name: Release

on:
  push:
    tags: ["v*.*.*"]

jobs:
  validate:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Run full test suite
        run: |
          xcodebuild test \
            -scheme Caos \
            -destination "platform=iOS Simulator,name=iPhone 16,OS=18.0" \
            -enableCodeCoverage YES \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
            | xcpretty

  release:
    runs-on: macos-15
    needs: validate
    steps:
      - uses: actions/checkout@v4

      - name: Validate Podspec
        run: pod lib lint Caos.podspec --allow-warnings

      - name: Push to CocoaPods
        run: pod trunk push Caos.podspec --allow-warnings
        env:
          COCOAPODS_TRUNK_TOKEN: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
          files: |
            CHANGELOG.md
```

---

### `nightly.yml` — Validação Noturna

**Gatilho:** `cron: '0 2 * * *'`

```yaml
name: Nightly

on:
  schedule:
    - cron: '0 2 * * *'

jobs:
  full-matrix:
    runs-on: macos-15
    strategy:
      matrix:
        ios: ["16.0", "17.0", "18.0"]
    steps:
      - uses: actions/checkout@v4
      - name: Test on iOS ${{ matrix.ios }}
        run: |
          xcodebuild test \
            -scheme Caos \
            -destination "platform=iOS Simulator,name=iPhone 16,OS=${{ matrix.ios }}" \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
            | xcpretty

  spm-validation:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Build via SPM
        run: swift build
      - name: Test via SPM
        run: swift test --enable-code-coverage
```

---

## Estrutura de Branches e Proteções

### Pré-requisito: Criar `develop`

A branch `develop` não existe ainda. Criar manualmente:

```bash
git checkout main
git checkout -b develop
git push -u origin develop
```

### Regras no GitHub

**Branch `main`:**
- Require PR com mínimo 1 aprovação
- Require CI verde (`ci.yml` completo)
- Require cobertura ≥ 90% (via Codecov status check)
- No direct push
- Linear history (no merge commits)

**Branch `develop`:**
- Require CI verde (`lint.yml` + `ci.yml`)
- No direct push (exceto `Agent-CI`)

### Dangerfile

```ruby
# Dangerfile
warn "PR muito grande (#{git.lines_of_code} linhas). Considere dividir." if git.lines_of_code > 500

fail "PR sem descrição." if github.pr_body.length < 50

warn "Sem testes para mudanças em Sources/." if git.modified_files.include?("Sources/") &&
  !git.modified_files.include?("Tests/")

fail "ViewModel detectado — padrão MV não permite ViewModels." if git.modified_files.any? { |f|
  File.read(f).include?("ViewModel") rescue false
}

message "Cobertura verificada via Codecov." if status_report[:errors].empty?
```

---

## Métricas de Qualidade

| Métrica | Meta |
|---|---|
| Cobertura de testes | ≥ 90% por fase |
| Violations SwiftLint | 0 (strict mode) |
| Build time (CI) | < 5 minutos |
| Tempo de feedback (lint) | < 2 minutos |
| Suporte mínimo iOS | iOS 16 |
| Compatibilidade Xcode | 16+ |
| Swift version | 5.9+ |
| ViewModels no codebase | 0 (Dangerfile bloqueia) |

---

## Resumo de Entregas por Fase

| Fase | Branch | Arquivos Novos/Modificados | Testes |
|---|---|---|---|
| 0 — Setup | `feature/phase-0-setup` | Remoção `.travis.yml`, Podspec/Podfile iOS 16, `Package.swift` stub | — |
| 1 — Schema | `feature/phase-1-schema` | `CaosSchema`, `CaosShard`, `CaosProps`, fixtures YAML, guia migração | `CaosParserTests` |
| 2 — Props | `feature/phase-2-props` | `CaosShimmerView`, shards com `configure(with:)`, shimmer real | `CaosEngineTests` |
| 3 — Binding | `feature/phase-3-store` | `CaosStore` (`@Observable`), `CaosDataBinding`, deprecações | `CaosStoreTests` |
| 4 — SwiftUI MV | `feature/phase-4-swiftui` | `CaosScreenView`, `CaosEnvironment`, `CaosCoordinator` | `CaosSwiftUITests` |
| 5 — Distribuição | `feature/phase-5-distribution` | `Package.swift` completo, README, CHANGELOG, CLI, GitHub Actions | — |
