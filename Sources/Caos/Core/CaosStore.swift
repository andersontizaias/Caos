import Foundation
import Combine

/// Central Model for the Caos MV architecture.
/// Manages data providers, reactive publishers, and shard type registration.
public final class CaosStore {

    // MARK: - Private state

    private var providers: [String: () -> Any] = [:]
    private var subjects: [String: CurrentValueSubject<Any, Never>] = [:]
    private var shardRegistry: [String: any CaosView.Type] = [:]
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    // MARK: - Data registration

    /// Registers a synchronous value provider for a key.
    public func register<T>(key: String, provider: @escaping () -> T) {
        providers[key] = { provider() }
        subjects[key]?.send(provider() as Any)
    }

    /// Registers a Combine publisher whose values are stored and emitted for a key.
    public func register<T>(key: String, publisher: AnyPublisher<T, Never>) {
        let subject = subjects[key] ?? CurrentValueSubject<Any, Never>(NSNull())
        subjects[key] = subject
        publisher
            .map { $0 as Any }
            .subscribe(subject)
            .store(in: &cancellables)
    }

    // MARK: - Shard type registration

    /// Registers a CaosView subclass for a given YAML type string.
    /// Replaces NSClassFromString coupling — app owns the mapping.
    public func register(type: String, view: any CaosView.Type) {
        shardRegistry[type] = view
    }

    // MARK: - Resolution

    /// Resolves the current value for a key synchronously.
    public func resolve<T>(key: String) -> T? {
        if let provider = providers[key] {
            return provider() as? T
        }
        if let value = subjects[key]?.value, !(value is NSNull) {
            return value as? T
        }
        return nil
    }

    /// Returns a publisher that emits typed values whenever the store updates a key.
    public func publisher<T>(for key: String) -> AnyPublisher<T, Never>? {
        guard let subject = subjects[key] else { return nil }
        return subject
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }

    /// Returns the registered CaosView type for a given YAML type string.
    public func viewType(for type: String) -> (any CaosView.Type)? {
        return shardRegistry[type]
    }
}
