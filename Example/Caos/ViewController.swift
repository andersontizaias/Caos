import UIKit
import SwiftUI
import Caos

class ViewController: UIViewController {

    private let store = CaosStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
        embedCaosScreen()
    }

    private func setupStore() {
        store.register(type: "CaosExample.CaosViewCard", view: CaosViewCard.self)
        store.register(type: "CaosExample.CaosViewShortcuts", view: CaosViewShortcuts.self)
        store.register(type: "CaosExample.CaosViewShortcutsChain", view: CaosViewShortcutsChain.self)
        store.register(type: "CaosExample.CaosViewShortcutsChainShimmer", view: CaosViewShortcutsChainShimmer.self)
        store.register(key: "balance") { "R$30.000,00" }
    }

    private func embedCaosScreen() {
        let caosView = CaosScreenView(name: "caos")
            .caosStore(store)
            .onCaosTap { id, _ in
                print("Tap em shard: \(id)")
            }
            .background(Color(.systemBackground))

        let hosting = UIHostingController(rootView: caosView)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
