# Contributing to Caos

Obrigado pelo interesse em contribuir! Siga as diretrizes abaixo.

## Fluxo de trabalho

1. Fork o repositório e crie sua branch a partir de `develop`:
   ```bash
   git checkout develop
   git checkout -b feature/minha-feature
   ```

2. Implemente sua mudança seguindo as diretrizes abaixo

3. Garanta que os testes passam e cobertura ≥ 90%:
   ```bash
   swift test --enable-code-coverage
   ```

4. Abra um Pull Request para `develop` (não para `main`)

## Padrões de código

- **Arquitetura MV**: sem ViewModels. Views lêem de `CaosStore` via `@Environment`
- **Nenhum ViewModel**: o Dangerfile bloqueia PRs com classes contendo "ViewModel"
- **SwiftLint**: `swiftlint --strict` deve passar com 0 violations
- **SwiftFormat**: `swiftformat --lint Sources Tests`
- **iOS 16+**: não use APIs exclusivas de iOS 17+ sem guard de disponibilidade
- **Stdlib only no parser**: `CaosParser` não pode ter dependências externas

## Adicionando um novo tipo de shard

1. Crie sua view conformando a `CaosView` (UIKit) ou `CaosSwiftUIView` (SwiftUI)
2. Documente as `CaosProps` aceitas com tipos e valores padrão
3. Implemente `configure(with:)`, `showLoading()` e `hideLoading()`
4. Registre via `CaosStore.register(type:view:)` no app consumidor
5. Adicione testes unitários cobrindo as props

## Adicionando suporte a novas props

1. Aceite o novo campo em `configure(with props: CaosProps)`
2. Use os acessores tipados: `props.string()`, `props.double()`, `props.color()`
3. Nunca faça fallback silencioso — use `?? defaultValue` explicitamente
4. Atualize o README com a nova prop na tabela de referência

## Testes

- Cobertura mínima: **90%** por arquivo novo
- Testes devem usar mocks concretos — sem force unwrap em testes
- Fixtures YAML ficam em `Tests/CaosTests/Fixtures/`

## Commits

Use prefixos semânticos:
- `feat:` — nova funcionalidade
- `fix:` — correção de bug
- `refactor:` — refatoração sem mudança de comportamento
- `test:` — adição ou correção de testes
- `docs:` — documentação
- `chore:` — configuração, CI, dependências

## Código de conduta

Seja respeitoso. Críticas são bem-vindas, ataques pessoais não.
