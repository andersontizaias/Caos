import SwiftUI

// MARK: - Environment Key

@available(iOS 16.0, macOS 13.0, *)
private struct CaosStoreKey: EnvironmentKey {
    static let defaultValue = CaosStore()
}

@available(iOS 16.0, macOS 13.0, *)
public extension EnvironmentValues {
    var caosStore: CaosStore {
        get { self[CaosStoreKey.self] }
        set { self[CaosStoreKey.self] = newValue }
    }
}

// MARK: - View modifier

@available(iOS 16.0, macOS 13.0, *)
public extension View {
    func caosStore(_ store: CaosStore) -> some View {
        environment(\.caosStore, store)
    }
}
