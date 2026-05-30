import XCTest
import Combine
@testable import Caos

final class CaosDataBindingTests: XCTestCase {

    var store: CaosStore!
    var binding: CaosDataBinding!

    override func setUp() {
        super.setUp()
        store = CaosStore()
        binding = CaosDataBinding()
    }

    override func tearDown() {
        binding.unbind()
        binding = nil
        store = nil
        super.tearDown()
    }

    // MARK: - Synchronous binding

    func test_bind_setsInitialLabelText() {
        store.register(key: "user.balance") { "R$500,00" }
        let label = UILabel()
        binding.bind(label: label, props: CaosProps(["dataKey": "user.balance"]), store: store)
        XCTAssertEqual(label.text, "R$500,00")
    }

    func test_bind_noDataKey_doesNotSetText() {
        let label = UILabel()
        label.text = "original"
        binding.bind(label: label, props: CaosProps(["title": "Hello"]), store: store)
        XCTAssertEqual(label.text, "original")
    }

    func test_bind_missingKey_doesNotCrash() {
        let label = UILabel()
        XCTAssertNoThrow(
            binding.bind(label: label, props: CaosProps(["dataKey": "missing.key"]), store: store)
        )
    }

    // MARK: - Reactive binding

    func test_bind_publisher_updatesLabel_onEmit() {
        let subject = CurrentValueSubject<String, Never>("initial")
        store.register(key: "live.value", publisher: subject.eraseToAnyPublisher())

        let label = UILabel()
        binding.bind(label: label, props: CaosProps(["dataKey": "live.value"]), store: store)

        let expectation = XCTestExpectation(description: "label updated")
        subject.send("updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { expectation.fulfill() }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(label.text, "updated")
    }

    // MARK: - Unbind

    func test_unbind_stopsUpdates() {
        let subject = CurrentValueSubject<String, Never>("start")
        store.register(key: "temp", publisher: subject.eraseToAnyPublisher())

        let label = UILabel()
        binding.bind(label: label, props: CaosProps(["dataKey": "temp"]), store: store)
        binding.unbind()

        subject.send("after-unbind")
        let exp = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotEqual(label.text, "after-unbind")
    }

    func test_unbind_multipleTimes_doesNotCrash() {
        XCTAssertNoThrow(binding.unbind())
        XCTAssertNoThrow(binding.unbind())
    }
}
