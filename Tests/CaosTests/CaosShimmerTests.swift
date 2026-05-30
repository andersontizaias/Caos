import XCTest
import UIKit
@testable import Caos

final class CaosShimmerTests: XCTestCase {

    func test_shimmerView_initiallyHidden() {
        let shimmer = CaosShimmerView()
        XCTAssertTrue(shimmer.isHidden)
    }

    func test_startShimmer_makesVisible() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        shimmer.startShimmer()
        XCTAssertFalse(shimmer.isHidden)
    }

    func test_stopShimmer_hidesView() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        shimmer.startShimmer()
        shimmer.stopShimmer()
        XCTAssertTrue(shimmer.isHidden)
    }

    func test_startShimmer_addsAnimationToGradientLayer() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        shimmer.layoutIfNeeded()
        shimmer.startShimmer()
        let gradientLayer = shimmer.layer.sublayers?.first(where: { $0 is CAGradientLayer })
        XCTAssertNotNil(gradientLayer?.animation(forKey: "shimmer"))
    }

    func test_stopShimmer_removesAnimation() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        shimmer.layoutIfNeeded()
        shimmer.startShimmer()
        shimmer.stopShimmer()
        let gradientLayer = shimmer.layer.sublayers?.first(where: { $0 is CAGradientLayer })
        XCTAssertNil(gradientLayer?.animation(forKey: "shimmer"))
    }

    func test_shimmerView_hasGradientLayer() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        shimmer.layoutIfNeeded()
        let hasGradient = shimmer.layer.sublayers?.contains { $0 is CAGradientLayer } ?? false
        XCTAssertTrue(hasGradient)
    }

    func test_startStopCycle_idempotent() {
        let shimmer = CaosShimmerView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        for _ in 0..<5 {
            shimmer.startShimmer()
            shimmer.stopShimmer()
        }
        XCTAssertTrue(shimmer.isHidden)
    }

    func test_gradientLayer_fillsViewBounds() {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 80)
        let shimmer = CaosShimmerView(frame: frame)
        shimmer.layoutIfNeeded()
        let gradientLayer = shimmer.layer.sublayers?.first(where: { $0 is CAGradientLayer })
        XCTAssertEqual(gradientLayer?.frame, frame)
    }
}
