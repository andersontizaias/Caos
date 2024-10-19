//
//  CaosEngineDelegate.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 11/10/23.
//

import Foundation

public protocol CaosEngineDelegate: AnyObject {
    var rootView: UIView { get }
    func didTapCardView(context: String)
    func requestDataForLabel() -> String
}
