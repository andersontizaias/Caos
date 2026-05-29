//
//  CaosSchema.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 29/05/26.
//

import Foundation

public struct CaosSchema {
    public let version: Int
    public let screens: [CaosScreen]

    public init(version: Int, screens: [CaosScreen]) {
        self.version = version
        self.screens = screens
    }
}
