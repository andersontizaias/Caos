import SwiftUI

// MARK: - Environment Key

private struct CaosStoreKey: EnvironmentKey {
    static let defaultValue = CaosStore()
}

public extension EnvironmentValues {
    var caosStore: CaosStore {
        get { self[CaosStoreKey.self] }
        set { self[CaosStoreKey.self] = newValue }
    }
}

// MARK: - View modifier

public extension View {
    /// Injects a CaosStore into the SwiftUI environment for all descendant views and shards.
    func caosStore(_ store: CaosStore) -> some View {
        environment(\.caosStore, store)
    }
}
