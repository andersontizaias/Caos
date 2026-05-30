#if canImport(UIKit)
import SwiftUI

/// SwiftUI-native wrapper for a Caos screen defined in a YAML file.
/// Follows the MV pattern: no ViewModel, store injected via @Environment.
///
/// Simple usage:
/// ```swift
/// CaosScreenView(name: "home", bundle: .main)
/// ```
///
/// With injected store:
/// ```swift
/// CaosScreenView(name: "home", bundle: .main)
///     .caosStore(myStore)
/// ```
@available(iOS 16.0, *)
public struct CaosScreenView: UIViewRepresentable {

    public let name: String
    public let bundle: Bundle

    @Environment(\.caosStore) private var store

    public init(name: String, bundle: Bundle = .main) {
        self.name = name
        self.bundle = bundle
    }

    public func makeCoordinator() -> CaosCoordinator {
        CaosCoordinator(store: store)
    }

    public func makeUIView(context: Context) -> UIScrollView {
        guard let engine = Caos.configure(
            bundle: bundle,
            name: name,
            target: context.coordinator,
            store: store
        ) else {
            return UIScrollView()
        }
        return engine.getScreenByIndex(index: 0) as? UIScrollView ?? UIScrollView()
    }

    public func updateUIView(_ uiView: UIScrollView, context: Context) {}
}
#endif
