import SwiftUI

/// Renderizado quando um tipo de shard não está registrado no CaosStore.
/// Em DEBUG mostra aviso visível; em Release usa EmptyView.
@available(iOS 16.0, macOS 13.0, *)
public struct CaosUnknownShardView: View {
    let type: String

    public init(type: String) {
        self.type = type
    }

    public var body: some View {
        #if DEBUG
            Text("⚠ Shard '\(type)' não registrado")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
                .background(Color(white: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        #else
            EmptyView()
        #endif
    }
}
