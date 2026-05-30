import XCTest
import UIKit
@testable import Caos

// MARK: - Mock shard for testing

final class MockCaosView: UIView, CaosView {
    weak var delegate: CaosEngineDelegate?
    var receivedProps: CaosProps?
    var configureCallCount = 0

    func configure(with props: CaosProps) {
        receivedProps = props
        configureCallCount += 1
    }
}

// MARK: - CaosEngineTests

final class CaosEngineTests: XCTestCase {

    func test_configure_receivesTitleProp() {
        let view = MockCaosView()
        let props = CaosProps(["title": "Hello"])
        view.configure(with: props)
        XCTAssertEqual(view.receivedProps?.string("title"), "Hello")
        XCTAssertEqual(view.configureCallCount, 1)
    }

    func test_configure_receivesDoubleProp() {
        let view = MockCaosView()
        let props = CaosProps(["cornerRadius": 12])
        view.configure(with: props)
        XCTAssertEqual(view.receivedProps?.double("cornerRadius"), 12.0)
    }

    func test_configure_missingProp_returnsNil() {
        let view = MockCaosView()
        view.configure(with: CaosProps())
        XCTAssertNil(view.receivedProps?.string("nonexistent"))
    }

    func test_defaultShowLoading_doesNotCrash() {
        let view = MockCaosView()
        XCTAssertNoThrow(view.showLoading())
    }

    func test_defaultHideLoading_doesNotCrash() {
        let view = MockCaosView()
        XCTAssertNoThrow(view.hideLoading())
    }

    func test_configure_colorProp_hexParsed() {
        let view = MockCaosView()
        let props = CaosProps(["bg": "#FF5500"])
        view.configure(with: props)
        XCTAssertNotNil(view.receivedProps?.color("bg"))
    }

    func test_props_allTypes() {
        let props = CaosProps([
            "str": "hello",
            "num": 42,
            "dbl": 3.14,
            "flag": true,
            "hex": "#AABBCC"
        ])
        XCTAssertEqual(props.string("str"), "hello")
        XCTAssertEqual(props.int("num"), 42)
        XCTAssertEqual(props.double("dbl"), 3.14, accuracy: 0.001)
        XCTAssertEqual(props.bool("flag"), true)
        XCTAssertNotNil(props.color("hex"))
    }

    func test_props_nestedProps() {
        let props = CaosProps(["padding": ["top": 24, "bottom": 16] as [String: Any]])
        let nested = props.nested("padding")
        XCTAssertNotNil(nested)
        XCTAssertEqual(nested?.int("top"), 24)
        XCTAssertEqual(nested?.int("bottom"), 16)
    }

    func test_props_arrayOfProps() {
        let items: [[String: Any]] = [
            ["label": "Pix", "icon": "arrow.circle"],
            ["label": "Simulador", "icon": "iphone.circle"]
        ]
        let props = CaosProps(["items": items])
        let arr = props.array("items")
        XCTAssertNotNil(arr)
        XCTAssertEqual(arr?.count, 2)
        XCTAssertEqual(arr?[0].string("label"), "Pix")
        XCTAssertEqual(arr?[1].string("icon"), "iphone.circle")
    }

    func test_shard_defaultValues() {
        let shard = CaosShard(type: "CardView")
        XCTAssertEqual(shard.type, "CardView")
        XCTAssertEqual(shard.id, "")
        XCTAssertNil(shard.props.string("anything"))
    }

    func test_shard_withAllValues() {
        let props = CaosProps(["title": "Test"])
        let shard = CaosShard(type: "BannerView", id: "banner_1", props: props)
        XCTAssertEqual(shard.type, "BannerView")
        XCTAssertEqual(shard.id, "banner_1")
        XCTAssertEqual(shard.props.string("title"), "Test")
    }

    func test_configure_calledMultipleTimes_updatesCount() {
        let view = MockCaosView()
        view.configure(with: CaosProps(["a": "1"]))
        view.configure(with: CaosProps(["b": "2"]))
        XCTAssertEqual(view.configureCallCount, 2)
        XCTAssertEqual(view.receivedProps?.string("b"), "2")
    }
}
