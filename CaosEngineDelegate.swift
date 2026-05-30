//
//  CaosEngineDelegate.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 11/10/23.
//

import Foundation

public protocol CaosEngineDelegate: AnyObject {
    var rootView: UIView { get }

    /// Called when any shard is tapped. Use `id` (from YAML) to identify the shard.
    func didTapShard(id: String, context: [String: Any])

    @available(*, deprecated, renamed: "didTapShard(id:context:)")
    func didTapCardView(context: String)

    @available(*, deprecated, message: "Use CaosStore.register(key:provider:) instead.")
    func requestDataForLabel() -> String
}

public extension CaosEngineDelegate {
    func didTapShard(id: String, context: [String: Any]) {}
    func didTapCardView(context: String) {}
    func requestDataForLabel() -> String { return "" }
}
