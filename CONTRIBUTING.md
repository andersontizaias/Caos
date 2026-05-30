# Contributing to Caos

Obrigado pelo interesse em contribuir! Siga as diretrizes abaixo.

## Setup do ambiente

```bash
# Clone e entre no diretório
git clone https://github.com/andersontizaias/Caos.git
cd Caos

# Gera o Caos.xcodeproj e o CaosExample.xcodeproj (requer Homebrew)
make setup

# Abre direto no Xcode
make open
```

O `Caos.xcodeproj` é **gerado** pelo XcodeGen e não versionado. A fonte de verdade é o `project.yml`.

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

4. Abra um Pull Request para `develop` com título no padrão Conventional Commits

## Padrões de código

- **Arquitetura MV**: sem ViewModels. Views lêem de `CaosStore` via `@Environment`
- **SwiftLint**: `swiftlint --strict` deve passar com 0 violations
- **SwiftFormat**: `swiftformat --lint Sources Tests`
- **iOS 16+**: não use APIs exclusivas de iOS 17+ sem guard de disponibilidade
- **Stdlib only no parser**: `CaosParser` não pode ter dependências externas

## Adicionando um novo tipo de shard

1. Crie sua view conformando a `CaosSwiftUIView`
2. Documente as `CaosProps` aceitas com tipos e valores padrão
3. Registre via `CaosStore.register(type:view:)` no app consumidor
4. Adicione testes unitários cobrindo as props

## Adicionando suporte a novas props

1. Aceite o novo campo em `var body: some View` via `props.string()`, `props.double()`, etc.
2. Nunca faça fallback silencioso — use `?? defaultValue` explicitamente
3. Atualize o README com a nova prop na tabela de referência

## Testes

- Cobertura mínima: **90%** por arquivo novo
- Testes devem usar mocks concretos — sem force unwrap em testes
- Fixtures YAML ficam em `Tests/CaosTests/Fixtures/`

## Commits — Conventional Commits

Todo commit e título de PR **devem** seguir o padrão [Conventional Commits](https://www.conventionalcommits.org/). O Danger bloqueia PRs que não seguem o formato.

### Formato

```
<tipo>(<escopo opcional>): <descrição curta>

[corpo opcional]

[BREAKING CHANGE: <descrição> — opcional]
```

### Tipos válidos

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade visível ao usuário |
| `fix` | Correção de bug |
| `docs` | Apenas documentação |
| `style` | Formatação, sem mudança de comportamento |
| `refactor` | Refatoração sem mudança de comportamento |
| `test` | Adição ou correção de testes |
| `chore` | CI, dependências, configuração, build |
| `perf` | Melhoria de performance |
| `ci` | Mudanças específicas nos workflows de CI |
| `build` | Sistema de build, Package.swift, XcodeGen |
| `revert` | Reverte um commit anterior |

### Exemplos

```bash
feat: adiciona suporte a container grid horizontal
fix(parser): corrige crash com YAML sem campo version
docs: adiciona exemplo de reactive binding no README
chore: atualiza XcodeGen para 2.43.0
feat!: remove suporte a YAML v0          # breaking change
```

### Breaking changes

Adicione `!` após o tipo ou inclua `BREAKING CHANGE:` no corpo para sinalizar que a versão major deve ser incrementada.

## Código de conduta

Seja respeitoso. Críticas são bem-vindas, ataques pessoais não.
