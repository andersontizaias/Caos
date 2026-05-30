import SwiftUI

/// Renderiza um CaosScreen usando containers SwiftUI nativos.
/// Escolhe ScrollView + LazyVStack / LazyHStack / LazyVGrid baseado em containerConfig.type.
@available(iOS 16.0, macOS 13.0, *)
struct CaosContainerView: View {
    let screen: CaosScreen
    @Environment(\.caosStore) private var store

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

    private var scrollAxis: Axis.Set {
        screen.containerConfig.type == "horizontal" ? .horizontal : .vertical
    }

    @ViewBuilder
    private var containerStack: some View {
        switch screen.containerConfig.type {
        case "horizontal":
            LazyHStack(spacing: screen.containerConfig.spacing) {
                shardViews
            }
        case "grid":
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: screen.containerConfig.spacing
            ) {
                shardViews
            }
        default: // "vertical"
            LazyVStack(spacing: screen.containerConfig.spacing) {
                shardViews
            }
        }
    }

    private var shardViews: some View {
        ForEach(Array(screen.shardList.enumerated()), id: \.offset) { _, shard in
            store.view(for: shard.type, props: shard.props)
        }
    }
}
