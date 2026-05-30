import SwiftUI

/// Protocolo que todo shard SwiftUI deve conformar.
/// O shard recebe props do YAML via init e acessa dados/eventos via @Environment.
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
@available(iOS 16.0, macOS 13.0, *)
public protocol CaosSwiftUIView: View {
    init(props: CaosProps)
}
