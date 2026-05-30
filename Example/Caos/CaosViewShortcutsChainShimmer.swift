import SwiftUI
import Caos

@available(iOS 16.0, *)
struct CaosViewShortcutsChainShimmer: CaosSwiftUIView {
    let props: CaosProps

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(white: 0.92))
            .frame(height: 100)
            .shimmer()
            .padding(.horizontal, 10)
    }
}
