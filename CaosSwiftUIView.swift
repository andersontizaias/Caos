import SwiftUI

/// Protocol for shards built entirely in SwiftUI.
/// Conformers receive props at init and access the store via @Environment — no ViewModel needed.
///
/// Example:
/// ```swift
/// struct BalanceCardView: View, CaosSwiftUIView {
///     let props: CaosProps
///     @Environment(\.caosStore) private var store
///
///     var body: some View {
///         Text(store.resolve(key: props.string("dataKey") ?? "") ?? "--")
///             .foregroundStyle(props.swiftUIColor("textColor") ?? .primary)
///     }
/// }
/// ```
@available(iOS 16.0, *)
public protocol CaosSwiftUIView: View {
    init(props: CaosProps)
}
