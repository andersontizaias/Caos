#if canImport(UIKit)
import UIKit

/// Bridge between UIKit CaosEngine events and the SwiftUI environment.
/// Acts as CaosEngineDelegate without being a ViewModel — forwards taps to the store.
@available(iOS 16.0, *)
public final class CaosCoordinator: NSObject, CaosEngineDelegate {

    private let store: CaosStore
    public var onTap: ((String, [String: Any]) -> Void)?

    public init(store: CaosStore) {
        self.store = store
    }

    public var rootView: UIView { UIView() }

    public func didTapShard(id: String, context: [String: Any]) {
        onTap?(id, context)
    }
}
#endif
