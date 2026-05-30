import Foundation

public struct CaosEdgeInsets: Sendable {
    public let top: CGFloat
    public let left: CGFloat
    public let bottom: CGFloat
    public let right: CGFloat

    public static let zero = CaosEdgeInsets()

    public init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

public struct CaosContainer {
    public let type: String         // "vertical" | "horizontal" | "grid"
    public let spacing: CGFloat
    public let padding: CaosEdgeInsets

    public init(type: String = "vertical", spacing: CGFloat = 0, padding: CaosEdgeInsets = .zero) {
        self.type = type
        self.spacing = spacing
        self.padding = padding
    }
}

public class CaosScreen {
    public var id: String = ""
    public var containerConfig: CaosContainer = CaosContainer()
    public var shardList: [CaosShard] = []

    public init() {}
}
