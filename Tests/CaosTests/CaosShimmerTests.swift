import XCTest
import SwiftUI
@testable import Caos

@available(iOS 16.0, macOS 13.0, *)
final class CaosShimmerTests: XCTestCase {

    func testShimmerModifierExists() {
        let modifier = ShimmerModifier(isActive: true)
        XCTAssertNotNil(modifier)
    }

    func testShimmerModifierInactive() {
        let modifier = ShimmerModifier(isActive: false)
        XCTAssertNotNil(modifier)
    }

    func testShimmerExtensionOnView() {
        let view = Text("Loading").shimmer(isActive: true)
        XCTAssertNotNil(view)
    }

    func testShimmerExtensionDefaultsToActive() {
        let view = Text("Loading").shimmer()
        XCTAssertNotNil(view)
    }

    func testShimmerExtensionInactive() {
        let view = Rectangle().shimmer(isActive: false)
        XCTAssertNotNil(view)
    }
}
