import Foundation
import Combine
import SwiftUI

/// Central Model for the Caos MV architecture.
/// Manages data providers, reactive publishers, and shard type registration.
public final class CaosStore: ObservableObject {

    // MARK: - Private state

    private var shardRegistry: [String: (CaosProps) -> AnyView] = [:]
    private var providers: [String: () -> Any] = [:]
    private var subjects: [String: CurrentValueSubject<Any, Never>] = [:]
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    // MARK: - Shard registration

    /// Registra um shard via closure type-erased.
    public func register(type: String, factory: @escaping (CaosProps) -> AnyView) {
        shardRegistry[type] = factory
    }

    /// Registra um shard via tipo que conforma CaosSwiftUIView.
    public func register<V: CaosSwiftUIView>(type: String, view: V.Type) {
        shardRegistry[type] = { props in AnyView(V(props: props)) }
    }

    /// Instancia a view para um shard. Retorna CaosUnknownShardView se tipo não registrado.
    public func view(for type: String, props: CaosProps) -> AnyView {
        guard let factory = shardRegistry[type] else {
            return AnyView(CaosUnknownShardView(type: type))
        }
        return factory(props)
    }

    // MARK: - Data registration

    /// Registra um provider síncrono para uma chave.
    public func register<T>(key: String, provider: @escaping () -> T) {
        providers[key] = { provider() }
        subjects[key]?.send(provider() as Any)
    }

    /// Registra um publisher Combine para uma chave.
    public func register<T>(key: String, publisher: AnyPublisher<T, Never>) {
        let subject = subjects[key] ?? CurrentValueSubject<Any, Never>(NSNull())
        subjects[key] = subject
        publisher
            .map { $0 as Any }
            .subscribe(subject)
            .store(in: &cancellables)
    }

    // MARK: - Resolution

    /// Resolve o valor atual de uma chave de forma síncrona.
    public func resolve<T>(key: String) -> T? {
        if let provider = providers[key] {
            return provider() as? T
        }
        if let value = subjects[key]?.value, !(value is NSNull) {
            return value as? T
        }
        return nil
    }

    /// Retorna um publisher que emite valores tipados quando a chave é atualizada.
    public func publisher<T>(for key: String) -> AnyPublisher<T, Never>? {
        guard let subject = subjects[key] else { return nil }
        return subject
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }
}
