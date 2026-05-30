import Foundation

public struct CaosSchema {
    public let version: Int
    public let screens: [CaosScreen]

    public init(version: Int, screens: [CaosScreen]) {
        self.version = version
        self.screens = screens
    }
}
