//
//  CaosView.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 22/10/23.
//

#if canImport(UIKit)
import UIKit

public protocol CaosView: UIView {
    var delegate: CaosEngineDelegate? { get set }
    func configure(with props: CaosProps)
    func showLoading()
    func hideLoading()
}

public extension CaosView {
    func showLoading() {}
    func hideLoading() {}
}
#endif
