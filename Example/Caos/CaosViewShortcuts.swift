//
//  CaosViewShortcuts.swift
//  Caos_Example
//
//  Created by Anderson Tiago Izaias on 18/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Caos

@available(iOS 13.0, *)
public class CaosViewShortcuts: UIView, CaosView {
    
    public var delegate: CaosEngineDelegate?

    let shardLabel: UILabel = {
        let label = UILabel()
        label.text = "O que você quer fazer?"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cardViewPCancellation: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Cancelamento"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.slash.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewPaymentLink: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Link de pagamento"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "gobackward"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewPSales: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Vendas"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewReceivavles: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Recebimentos"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "flag.checkered.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        addSubview(shardLabel)
        
        let leftStack = UIStackView(arrangedSubviews: [cardViewPCancellation, cardViewPSales])
        leftStack.axis = .vertical
        leftStack.distribution = .fillEqually
        leftStack.spacing = 10

        let rightStack = UIStackView(arrangedSubviews: [cardViewPaymentLink, cardViewReceivavles])
        rightStack.axis = .vertical
        rightStack.distribution = .fillEqually
        rightStack.spacing = 10

        let horizontalStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 15
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 360),
            shardLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            shardLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            horizontalStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            horizontalStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            horizontalStack.topAnchor.constraint(equalTo: shardLabel.bottomAnchor, constant: 10),
            horizontalStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
