@testable import Caos
import SwiftUI
import XCTest

@available(iOS 16.0, macOS 13.0, *)
final class CaosSwiftUITests: XCTestCase {
    // MARK: - CaosSwiftUIView protocol

    func testStubConformsToProtocol() {
        let view = StubView(props: CaosProps(["key": "value"]))
        XCTAssertNotNil(view)
    }

    func testPropsAccessibleInShard() {
        let props = CaosProps(["title": "Hello"])
        let view = StubView(props: props)
        XCTAssertEqual(view.props.string("title"), "Hello")
    }

    // MARK: - CaosEnvironment

    func testCaosStoreEnvironmentKeyDefaultValue() {
        let store = CaosStore()
        XCTAssertNotNil(store)
    }

    // MARK: - CaosTapHandler

    func testOnCaosTapModifierExists() {
        var tappedId = ""
        let view = Text("tap me").onCaosTap { id, _ in tappedId = id }
        XCTAssertNotNil(view)
        _ = tappedId
    }

    func testCaosTapActionDefaultDoesNothing() {
        let defaultAction: CaosTapAction = { _, _ in }
        defaultAction("anyId", [:])
    }

    // MARK: - CaosUnknownShardView

    func testUnknownShardViewCreation() {
        let view = CaosUnknownShardView(type: "unknown")
        XCTAssertNotNil(view)
    }

    // MARK: - CaosStore registry integration

    func testStoreViewForUnregisteredTypeReturnsView() {
        let store = CaosStore()
        let view = store.view(for: "unregistered", props: CaosProps())
        XCTAssertNotNil(view)
    }

    func testStoreViewForRegisteredTypeReturnsView() {
        let store = CaosStore()
        store.register(type: "stub", view: StubView.self)
        let view = store.view(for: "stub", props: CaosProps(["title": "Test"]))
        XCTAssertNotNil(view)
    }

    // MARK: - CaosEnvironment EnvironmentValues

    func testCaosStoreEnvironmentValues_getterSetter() {
        var values = EnvironmentValues()
        let store = CaosStore()
        store.register(type: "env_test", view: StubView.self)
        values.caosStore = store
        XCTAssertNotNil(values.caosStore)
    }

    // MARK: - CaosTapHandler EnvironmentValues

    func testCaosTapActionEnvironmentValues_getterSetter() {
        var values = EnvironmentValues()
        var received = ""
        values.caosTapAction = { id, _ in received = id }
        values.caosTapAction("shard_1", [:])
        XCTAssertEqual(received, "shard_1")
    }
}

// MARK: - Stub

@available(iOS 16.0, macOS 13.0, *)
private struct StubView: CaosSwiftUIView {
    let props: CaosProps
    var body: some View {
        EmptyView()
    }
}
