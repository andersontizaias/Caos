import UIKit
import Caos

@available(iOS 13.0, *)
public class CaosViewShortcutsChainShimmer: UIView, CaosView {

    public weak var delegate: CaosEngineDelegate?

    private let shimmer = CaosShimmerView()

    private let placeholderContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemFill
        addSubview(placeholderContainer)

        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.layer.cornerRadius = 15
        shimmer.clipsToBounds = true
        placeholderContainer.addSubview(shimmer)

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 130),
            placeholderContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            placeholderContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            placeholderContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            shimmer.topAnchor.constraint(equalTo: placeholderContainer.topAnchor),
            shimmer.bottomAnchor.constraint(equalTo: placeholderContainer.bottomAnchor),
            shimmer.leadingAnchor.constraint(equalTo: placeholderContainer.leadingAnchor),
            shimmer.trailingAnchor.constraint(equalTo: placeholderContainer.trailingAnchor),
        ])

        shimmer.startShimmer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with props: CaosProps) {}

    public func showLoading() { shimmer.startShimmer() }
    public func hideLoading() { shimmer.stopShimmer() }
}
