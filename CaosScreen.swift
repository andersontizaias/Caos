//
//  CaosScreen.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 12/10/23.
//

import UIKit

public struct CaosContainer {
    public let type: String         // "vertical" | "horizontal" | "grid"
    public let spacing: CGFloat
    public let padding: UIEdgeInsets

    public init(type: String = "vertical", spacing: CGFloat = 0, padding: UIEdgeInsets = .zero) {
        self.type = type
        self.spacing = spacing
        self.padding = padding
    }
}

public class CaosScreen {

    // MARK: - v1 properties

    public var id: String = ""
    public var containerConfig: CaosContainer = CaosContainer()
    public var shardList: [CaosShard] = []

    // MARK: - Deprecated v0 backward-compat properties (used by existing CaosEngine)

    @available(*, deprecated, message: "Use containerConfig.type instead")
    public var container: String {
        get { containerConfig.type }
        set { containerConfig = CaosContainer(type: newValue) }
    }

    @available(*, deprecated, message: "Use shardList instead")
    public var shards: [String] {
        get { shardList.map { $0.type } }
        set { shardList = newValue.map { CaosShard(type: $0) } }
    }

    // MARK: - Initializer

    public init() {}
}
