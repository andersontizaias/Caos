//
//  CaosView.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 22/10/23.
//

import UIKit

public protocol CaosView: UIView {
    var delegate: CaosEngineDelegate? { get set }
}
