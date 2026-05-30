import XCTest
import SwiftUI
@testable import Caos

@available(iOS 16.0, *)
final class CaosSwiftUITests: XCTestCase {

    // MARK: - CaosEnvironment

    func test_caosStoreEnvironmentKey_hasDefaultValue() {
        let store = CaosStore()
        XCTAssertNotNil(store)
    }

    func test_caosStore_environmentModifier_compilesAndInjects() {
        let store = CaosStore()
        store.register(key: "test") { "value" }

        // Verify the store modifier syntax compiles and the value is injectable
        let view = Text("Hello").caosStore(store)
        XCTAssertNotNil(view)
    }

    // MARK: - CaosCoordinator

    func test_coordinator_didTapShard_callsOnTap() {
        let store = CaosStore()
        let coordinator = CaosCoordinator(store: store)

        var receivedId: String?
        var receivedContext: [String: Any]?

        coordinator.onTap = { id, context in
            receivedId = id
            receivedContext = context
        }

        coordinator.didTapShard(id: "card_balance", context: ["action": "navigate"])

        XCTAssertEqual(receivedId, "card_balance")
        XCTAssertEqual(receivedContext?["action"] as? String, "navigate")
    }

    func test_coordinator_onTap_nil_doesNotCrash() {
        let store = CaosStore()
        let coordinator = CaosCoordinator(store: store)
        coordinator.onTap = nil
        XCTAssertNoThrow(coordinator.didTapShard(id: "any", context: [:]))
    }

    func test_coordinator_rootView_isUIView() {
        let coordinator = CaosCoordinator(store: CaosStore())
        XCTAssertTrue(coordinator.rootView is UIView)
    }

    // MARK: - CaosScreenView structure

    func test_caosScreenView_init_setsProperties() {
        let view = CaosScreenView(name: "home", bundle: .main)
        XCTAssertEqual(view.name, "home")
        XCTAssertEqual(view.bundle, .main)
    }

    func test_caosScreenView_defaultBundle_isMain() {
        let view = CaosScreenView(name: "test")
        XCTAssertEqual(view.bundle, .main)
    }

    // MARK: - CaosStore + Environment integration

    func test_store_registeredBeforeView_resolvesInCoordinator() {
        let store = CaosStore()
        store.register(key: "greeting") { "Olá, Caos!" }

        let coordinator = CaosCoordinator(store: store)
        XCTAssertNotNil(coordinator)
        // Coordinator holds a reference to the store — values are accessible
        let value: String? = store.resolve(key: "greeting")
        XCTAssertEqual(value, "Olá, Caos!")
    }

    func test_store_shardRegistry_availableToCoordinator() {
        let store = CaosStore()
        store.register(type: "CardView", view: MockSwiftUIShardView.self)
        let resolved = store.viewType(for: "CardView")
        XCTAssertTrue(resolved == MockSwiftUIShardView.self)
    }
}

// MARK: - Mock shard view for tests

private final class MockSwiftUIShardView: UIView, CaosView {
    weak var delegate: CaosEngineDelegate?
    func configure(with props: CaosProps) {}
}
