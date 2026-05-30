import XCTest
import Combine
@testable import Caos

final class CaosStoreTests: XCTestCase {

    var store: CaosStore!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        store = CaosStore()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        store = nil
        super.tearDown()
    }

    // MARK: - Synchronous provider

    func test_register_syncProvider_resolve_returnsValue() {
        store.register(key: "balance") { "R$1.000,00" }
        let result: String? = store.resolve(key: "balance")
        XCTAssertEqual(result, "R$1.000,00")
    }

    func test_register_syncProvider_resolve_wrongType_returnsNil() {
        store.register(key: "amount") { 42 }
        let result: String? = store.resolve(key: "amount")
        XCTAssertNil(result)
    }

    func test_register_multipleKeys_resolveIndependently() {
        store.register(key: "name") { "Anderson" }
        store.register(key: "age") { 30 }
        XCTAssertEqual(store.resolve(key: "name"), "Anderson")
        XCTAssertEqual(store.resolve(key: "age"), 30)
    }

    func test_resolve_unregisteredKey_returnsNil() {
        let result: String? = store.resolve(key: "nonexistent")
        XCTAssertNil(result)
    }

    func test_register_syncProvider_overwrite_returnsNewValue() {
        store.register(key: "val") { "first" }
        store.register(key: "val") { "second" }
        let result: String? = store.resolve(key: "val")
        XCTAssertEqual(result, "second")
    }

    // MARK: - Combine publisher

    func test_register_publisher_resolve_returnsCurrentValue() {
        let subject = CurrentValueSubject<String, Never>("initial")
        store.register(key: "live", publisher: subject.eraseToAnyPublisher())
        let result: String? = store.resolve(key: "live")
        XCTAssertEqual(result, "initial")
    }

    func test_register_publisher_emitsUpdates() {
        let subject = CurrentValueSubject<String, Never>("v1")
        store.register(key: "data", publisher: subject.eraseToAnyPublisher())

        var received: [String] = []
        let expectation = XCTestExpectation(description: "publisher emits v2")
        expectation.expectedFulfillmentCount = 2

        store.publisher(for: "data")?
            .sink { (value: String) in
                received.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        subject.send("v2")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(received.last, "v2")
    }

    func test_publisher_unregisteredKey_returnsNil() {
        let pub: AnyPublisher<String, Never>? = store.publisher(for: "missing")
        XCTAssertNil(pub)
    }

    // MARK: - Shard type registry

    func test_register_shardType_viewType_returnsCorrectType() {
        store.register(type: "CardView", view: MockShardViewA.self)
        let resolved = store.viewType(for: "CardView")
        XCTAssertTrue(resolved == MockShardViewA.self)
    }

    func test_viewType_unregistered_returnsNil() {
        XCTAssertNil(store.viewType(for: "UnknownView"))
    }

    func test_register_multipleShardTypes_resolveIndependently() {
        store.register(type: "CardView",   view: MockShardViewA.self)
        store.register(type: "BannerView", view: MockShardViewB.self)
        XCTAssertTrue(store.viewType(for: "CardView")   == MockShardViewA.self)
        XCTAssertTrue(store.viewType(for: "BannerView") == MockShardViewB.self)
    }

    func test_register_shardType_overwrite_returnsNewType() {
        store.register(type: "CardView", view: MockShardViewA.self)
        store.register(type: "CardView", view: MockShardViewB.self)
        XCTAssertTrue(store.viewType(for: "CardView") == MockShardViewB.self)
    }
}

// MARK: - Mock views

private final class MockShardViewA: UIView, CaosView {
    weak var delegate: CaosEngineDelegate?
    func configure(with props: CaosProps) {}
}

private final class MockShardViewB: UIView, CaosView {
    weak var delegate: CaosEngineDelegate?
    func configure(with props: CaosProps) {}
}
