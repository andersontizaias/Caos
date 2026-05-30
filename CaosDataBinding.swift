import UIKit
import Combine

/// Manages reactive data binding between CaosStore publishers and UIKit views.
/// Used by CaosView conformers to subscribe a UILabel to a store key via the `dataKey` prop.
public final class CaosDataBinding {

    private var cancellables = Set<AnyCancellable>()

    public init() {}

    /// Binds a UILabel's text to a CaosStore key specified in the `dataKey` prop.
    /// Sets the initial value synchronously and updates on every publisher emission.
    public func bind(label: UILabel, props: CaosProps, store: CaosStore) {
        guard let key = props.string("dataKey") else { return }

        if let initial: String = store.resolve(key: key) {
            label.text = initial
        }

        store.publisher(for: key)?
            .receive(on: DispatchQueue.main)
            .sink { [weak label] (value: String) in
                label?.text = value
            }
            .store(in: &cancellables)
    }

    /// Cancels all active bindings.
    public func unbind() {
        cancellables.removeAll()
    }
}
