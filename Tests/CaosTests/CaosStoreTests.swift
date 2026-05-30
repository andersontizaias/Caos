@testable import Caos
import Combine
import SwiftUI
import XCTest

@available(iOS 16.0, macOS 13.0, *)
final class CaosStoreTests: XCTestCase {
    var store: CaosStore!

    override func setUp() {
        super.setUp()
        store = CaosStore()
    }

    // MARK: - Data registration

    func testRegisterAndResolveSyncProvider() {
        store.register(key: "username") { "Anderson" }
        let value: String? = store.resolve(key: "username")
        XCTAssertEqual(value, "Anderson")
    }

    func testResolveUnregisteredKeyReturnsNil() {
        let value: String? = store.resolve(key: "nonexistent")
        XCTAssertNil(value)
    }

    func testResolveWrongTypeReturnsNil() {
        store.register(key: "count") { 42 }
        let value: String? = store.resolve(key: "count")
        XCTAssertNil(value)
    }

    func testRegisterProviderUpdatesValue() {
        store.register(key: "balance") { 100.0 }
        let first: Double? = store.resolve(key: "balance")
        store.register(key: "balance") { 200.0 }
        let second: Double? = store.resolve(key: "balance")
        XCTAssertEqual(first, 100.0)
        XCTAssertEqual(second, 200.0)
    }

    func testPublisherEmitsRegisteredValue() {
        let exp = expectation(description: "publisher emits")
        let subject = CurrentValueSubject<Int, Never>(99)
        store.register(key: "score", publisher: subject.eraseToAnyPublisher())
        let cancellable = store.publisher(for: "score")?.sink { (value: Int) in
            XCTAssertEqual(value, 99)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        _ = cancellable
    }

    func testPublisherForUnregisteredKeyReturnsNil() {
        let publisher: AnyPublisher<String, Never>? = store.publisher(for: "ghost")
        XCTAssertNil(publisher)
    }

    // MARK: - Shard registry

    func testRegisterFactoryAndViewReturnsAnyView() {
        store.register(type: "banner") { _ in AnyView(Text("Banner")) }
        let props = CaosProps(["title": "Hello"])
        let view = store.view(for: "banner", props: props)
        XCTAssertNotNil(view)
    }

    func testUnregisteredTypeReturnsUnknownView() {
        let props = CaosProps()
        let view = store.view(for: "unknown_xyz", props: props)
        XCTAssertNotNil(view)
    }

    func testRegisterViewTypeViaProtocol() {
        store.register(type: "stub", view: StubShardView.self)
        let view = store.view(for: "stub", props: CaosProps(["label": "test"]))
        XCTAssertNotNil(view)
    }

    func testMultipleShardTypesRegistered() {
        store.register(type: "a") { _ in AnyView(Text("A")) }
        store.register(type: "b") { _ in AnyView(Text("B")) }
        XCTAssertNotNil(store.view(for: "a", props: CaosProps()))
        XCTAssertNotNil(store.view(for: "b", props: CaosProps()))
    }
}

// MARK: - Test stub shard

@available(iOS 16.0, macOS 13.0, *)
private struct StubShardView: CaosSwiftUIView {
    let props: CaosProps
    var body: some View {
        Text(props.string("label") ?? "")
    }
}
