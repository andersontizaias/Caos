# Changelog

All notable changes to this project will be documented in this file.
Format: [Semantic Versioning](https://semver.org/).

---

## [1.0.0] — 2026-05-29

### Added
- **YAML Schema v1** — hierarchical, versionado, padrão YAML real
- **CaosProps** — dicionário tipado de propriedades (`string`, `int`, `double`, `bool`, `color`, `nested`, `array`)
- **CaosShard** — modelo de shard com `type`, `id`, `props`
- **CaosSchema** — modelo raiz com `version` e `screens`
- **CaosParser** — reescrita completa; suporta YAML v1 hierárquico sem dependências externas
- **CaosStore** — Model central (padrão MV) com providers síncronos e publishers Combine
- **CaosDataBinding** — binding reativo `UILabel` ↔ `CaosStore` via `dataKey`
- **CaosShimmerView** — shimmer genérico reutilizável com `CAGradientLayer`
- **CaosScreenView** — wrapper SwiftUI (`UIViewRepresentable`) para telas Caos
- **CaosSwiftUIView** — protocolo para shards SwiftUI puros
- **CaosCoordinator** — bridge UIKit→SwiftUI sem ViewModel
- **CaosEnvironment** — `EnvironmentKey` + `.caosStore()` modifier
- **caos-lint** — CLI de validação de YAML via SPM
- **Swift Package Manager** — suporte completo com targets `Caos` e `caos-lint`
- **GitHub Actions** — workflows `lint.yml`, `ci.yml`, `release.yml`, `nightly.yml`
- Testes unitários: `CaosParserTests`, `CaosEngineTests`, `CaosShimmerTests`, `CaosStoreTests`, `CaosDataBindingTests`, `CaosSwiftUITests`
- Docs: guias de migração v0→v1 e delegate→CaosStore

### Changed
- `CaosView` protocol: adicionado `configure(with:)`, `showLoading()`, `hideLoading()` (com default no-op)
- `CaosEngine`: chama `configure(with: shard.props)` em cada shard; aceita `CaosStore` opcional
- `CaosScreen`: adicionado `id`, `containerConfig: CaosContainer`, `shardList: [CaosShard]`
- `Caos.configure`: nova sobrecarga aceitando `CaosStore` (compatível com versão anterior)
- Deployment target: iOS 10.0 → **iOS 16.0**
- Estrutura de diretórios: reorganizada para `Sources/Caos/{Core,Schema,UI,SwiftUI}/`

### Deprecated
- `CaosEngineDelegate.requestDataForLabel()` → use `CaosStore.register(key:provider:)`
- `CaosEngineDelegate.didTapCardView(context:)` → use `didTapShard(id:context:)`
- `CaosParser.init(content:)` e `getScreens()` → use `CaosParser.parse(_:)`
- `CaosScreen.container: String` → use `containerConfig.type`
- `CaosScreen.shards: [String]` → use `shardList`

### Removed
- `.travis.yml` — substituído por GitHub Actions
- `CaosEngine.randomizeUIColor()` — método privado sem uso

---

## [0.1.0] — 2023-10-08

### Added
- Versão inicial do framework Caos
- `CaosParser` simples (formato v0, linha-a-linha)
- `CaosEngine` com `NSClassFromString` para instanciar views
- `CaosView` protocolo base
- `CaosEngineDelegate` com `didTapCardView` e `requestDataForLabel`
- Exemplo de app com `CaosViewCard`, `CaosViewShortcuts`, `CaosViewShortcutsChain`
