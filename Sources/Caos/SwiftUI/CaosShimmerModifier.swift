import SwiftUI

/// ViewModifier que aplica efeito shimmer de carregamento sobre qualquer view.
/// Usa o sistema de animação SwiftUI — sem CALayer, sem UIKit.
///
/// Uso:
/// ```swift
/// Text("Carregando...")
///     .redacted(reason: .placeholder)
///     .shimmer(isActive: isLoading)
///
/// Rectangle()
///     .shimmer()
/// ```
public struct ShimmerModifier: ViewModifier {
    let isActive: Bool

    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isActive {
                        shimmerOverlay
                    }
                }
            )
            .animation(.easeInOut(duration: 0.3), value: isActive)
            .onAppear {
                guard isActive else { return }
                _startAnimation()
            }
            .onChange(of: isActive) { active in
                if active { _startAnimation() } else { phase = 0 }
            }
    }

    // MARK: - Private

    var shimmerOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            LinearGradient(
                colors: [
                    Color(white: 0.88),
                    Color(white: 0.78),
                    Color(white: 0.88),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 3)
            .offset(x: (phase * width * 3) - width)
        }
        .clipped()
        .allowsHitTesting(false)
    }

    func _startAnimation() {
        phase = 0
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }
}

public extension View {
    /// Aplica efeito shimmer de carregamento.
    /// - Parameter isActive: controla se o shimmer está visível e animando.
    func shimmer(isActive: Bool = true) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}
