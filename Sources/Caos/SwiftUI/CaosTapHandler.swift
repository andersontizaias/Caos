import SwiftUI

public typealias CaosTapAction = (String, [String: Any]) -> Void

@available(iOS 16.0, macOS 13.0, *)
private struct CaosTapActionKey: EnvironmentKey {
    static let defaultValue: CaosTapAction = { _, _ in }
}

@available(iOS 16.0, macOS 13.0, *)
public extension EnvironmentValues {
    var caosTapAction: CaosTapAction {
        get { self[CaosTapActionKey.self] }
        set { self[CaosTapActionKey.self] = newValue }
    }
}

@available(iOS 16.0, macOS 13.0, *)
public extension View {
    /// Define o handler de toque para todos os shards descendentes.
    /// O `id` vem do campo `id:` do shard no YAML.
    func onCaosTap(_ action: @escaping CaosTapAction) -> some View {
        environment(\.caosTapAction, action)
    }
}
