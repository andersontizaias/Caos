//
//  CaosViewCard.swift
//  Caos_Example
//
//  Created by Anderson Tiago Izaias on 17/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Caos

@available(iOS 13.0, *)
public class CaosViewCard: UIView, CaosView {
    
    public var delegate: CaosEngineDelegate?
    
    
    let shardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    let shardLabel: UILabel = {
        let label = UILabel()
        label.text = "Antecipação de recebiveis"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total disponível:"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalValue: UILabel = {
        let label = UILabel()
        label.text = "R$10.000,00"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "dollarsign.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        shardView.addSubview(shardLabel)
        shardView.addSubview(totalLabel)
        shardView.addSubview(totalValue)
        shardView.addSubview(imageView)
        addSubview(shardView)
        
        setupGesture()
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 130),
            shardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
            shardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            shardView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            shardLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
            shardLabel.topAnchor.constraint(equalTo: shardView.topAnchor, constant: 5),
            totalLabel.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            totalLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 85),
            totalValue.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            totalValue.leadingAnchor.constraint(equalTo: totalLabel.trailingAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 20),
            imageView.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlerTap))
        shardView.addGestureRecognizer(tap)
    }
    
    public func configure(with props: CaosProps) {
        if let title = props.string("title") { shardLabel.text = title }
        if let valueLabel = props.string("valueLabel") { totalLabel.text = valueLabel }
        if let bg = props.color("backgroundColor") { shardView.backgroundColor = bg }
        if let radius = props.double("cornerRadius") { shardView.layer.cornerRadius = CGFloat(radius) }
        if let iconName = props.string("iconName") { imageView.image = UIImage(systemName: iconName) }
        if let iconColor = props.color("iconColor") { imageView.tintColor = iconColor }
    }

    @objc func handlerTap(){
        delegate?.didTapCardView(context: "Click Here")
        totalValue.text = delegate?.requestDataForLabel()
    }
}
