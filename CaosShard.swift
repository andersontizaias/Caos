//
//  CaosShard.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 29/05/26.
//

import Foundation

public struct CaosShard {
    public let type: String
    public let id: String
    public let props: CaosProps

    public init(type: String, id: String = "", props: CaosProps = CaosProps()) {
        self.type = type
        self.id = id
        self.props = props
    }
}
