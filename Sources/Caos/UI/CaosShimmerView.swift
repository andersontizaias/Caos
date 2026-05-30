#if canImport(UIKit)
import UIKit

public final class CaosShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations  = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
        isHidden = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    public func startShimmer() {
        isHidden = false
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue    = [-1.0, -0.5, 0.0]
        animation.toValue      = [1.0,  1.5,  2.0]
        animation.duration     = 1.2
        animation.repeatCount  = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "shimmer")
    }

    public func stopShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmer")
        isHidden = true
    }
}
#endif
