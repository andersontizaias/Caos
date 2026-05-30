# Migração: Delegate → CaosStore

Guia para migrar do padrão de delegate manual de dados para o `CaosStore` reativo (arquitetura MV).

---

## Visão Geral da Mudança

O padrão anterior exigia que o `ViewController` implementasse métodos de delegate para fornecer dados aos shards (`requestDataForLabel()`) e para tratar eventos de tap (`didTapCardView(context:)`). Esse modelo não escalava: cada novo dado exigia um novo método no protocolo, e não havia suporte a atualizações reativas.

O `CaosStore` resolve esses problemas centralizando o estado como um **Model** (padrão MV). O app registra provedores de dados por chave (`dataKey`) e os shards resolvem os valores dinamicamente — inclusive reagindo a publishers Combine sem código adicional no ViewController.

---

## O que foi depreciado

| Método depreciado | Substituto |
|---|---|
| `requestDataForLabel() -> String` | `CaosStore.register(key:provider:)` |
| `didTapCardView(context: String)` | `didTapShard(id:context:)` |

Os métodos depreciados ainda compilam e funcionam — apenas geram warnings. A remoção definitiva ocorrerá na v2.0.

---

## Guia Passo a Passo

### Passo 1 — Criar e configurar o CaosStore

```swift
// ANTES — nenhuma configuração necessária, dados vinham via delegate

// DEPOIS — crie o store e registre os provedores
let store = CaosStore()
store.register(key: "user.balance") { UserSession.current.formattedBalance }
store.register(key: "user.name")    { UserSession.current.name }
```

### Passo 2 — Registro reativo com Combine (opcional)

```swift
// ANTES — sem atualização reativa; o shard exibia o valor fixo do momento do tap
func requestDataForLabel() -> String {
    return UserSession.current.formattedBalance
}

// DEPOIS — o shard atualiza automaticamente quando o publisher emite
store.register(
    key: "user.balance",
    publisher: UserSession.shared.$balance
        .map { $0.formatted(.currency(code: "BRL")) }
        .eraseToAnyPublisher()
)
```

### Passo 3 — Passar o store para `Caos.configure`

```swift
// ANTES
let engine = Caos.configure(bundle: .main, name: "caos", target: self)

// DEPOIS — store é injetado automaticamente nos shards
let engine = Caos.configure(bundle: .main, name: "caos", target: self, store: store)
```

### Passo 4 — Tratar eventos de tap

```swift
// ANTES
func didTapCardView(context: String) {
    print("Tapped: \(context)")
}

// DEPOIS — id identifica o shard pelo campo 'id' do YAML, context é extensível
func didTapShard(id: String, context: [String: Any]) {
    switch id {
    case "card_balance": navigateToBalance()
    case "shortcuts_pix": navigateToPix()
    default: break
    }
}
```

### Passo 5 — Usar `dataKey` no YAML

```yaml
# ANTES — valor hardcoded no shard
shards:
  - type: Caos_Example.CaosViewCard
    id: card_balance

# DEPOIS — valor resolvido dinamicamente pelo CaosStore
shards:
  - type: Caos_Example.CaosViewCard
    id: card_balance
    props:
      dataKey: "user.balance"
      title: "Saldo disponível"
      backgroundColor: "#FFFFFF"
```

### Passo 6 — Implementar `configure(with:)` no shard com binding

```swift
public class BalanceCardView: UIView, CaosView {
    private let valueLabel = UILabel()
    private let binding = CaosDataBinding()
    public weak var delegate: CaosEngineDelegate?

    public func configure(with props: CaosProps) {
        if let title = props.string("title") {
            titleLabel.text = title
        }
        // Binding reativo: CaosDataBinding observa o store via dataKey
        // binding.bind(label: valueLabel, props: props, store: store)
        // Nota: injeção automática de store via CaosView.store — disponível na Fase 4
    }
}
```

---

## Compatibilidade com código existente

Os métodos depreciados geram warnings de compilação mas **não quebram o app**:

```
⚠ 'requestDataForLabel()' is deprecated: Use CaosStore.register(key:provider:) instead.
⚠ 'didTapCardView(context:)' is deprecated: renamed to 'didTapShard(id:context:)'
```

O ViewController existente continua compilando sem alterações. Migre no seu próprio ritmo.

---

## Referências

- [Plano de Evolução completo](../PLAN_IOS.md)
- [Migração YAML v0 → v1](Migration_v0_to_v1.md)
