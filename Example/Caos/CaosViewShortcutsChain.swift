//
//  CaosView.swift
//  Caos_Example
//
//  Created by Anderson Tiago Izaias on 16/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Caos

@available(iOS 13.0, *)
public class CaosViewShortcutsChain: UIView, CaosView {
    
    weak public var delegate: CaosEngineDelegate?

    private let shimmer = CaosShimmerView()

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
        label.text = "Minha Rede"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution  = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let cardViewSimulador: UIView = {
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
        label.text = "Simulador"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.circle"))
        imageView.tintColor = .orange
       // imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    let cardViewPix: UIView = {
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
        label.text = "Pix"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "arrow.left.arrow.right.circle"))
        imageView.tintColor = .orange
       // imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    let cardViewAnticipation: UIView = {
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
        label.text = "Antecipação"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "dollarsign.circle"))
        imageView.tintColor = .orange
        //imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
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
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.slash.circle"))
        imageView.tintColor = .orange
        //imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
   
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        shardView.addSubview(shardLabel)
        hStackView.addArrangedSubview(cardViewSimulador)
        hStackView.addArrangedSubview(cardViewPix)
        hStackView.addArrangedSubview(cardViewAnticipation)
        hStackView.addArrangedSubview(cardViewPCancellation)
        shardView.addSubview(hStackView)
        addSubview(shardView)

        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.layer.cornerRadius = 15
        shimmer.clipsToBounds = true
        addSubview(shimmer)

        setupGesture()

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 130),
            shimmer.topAnchor.constraint(equalTo: topAnchor),
            shimmer.bottomAnchor.constraint(equalTo: bottomAnchor),
            shimmer.leadingAnchor.constraint(equalTo: leadingAnchor),
            shimmer.trailingAnchor.constraint(equalTo: trailingAnchor),
                   shardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
                   shardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                   shardView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                   shardLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
                   shardLabel.topAnchor.constraint(equalTo: shardView.topAnchor, constant: 5),
                   hStackView.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
                   hStackView.trailingAnchor.constraint(equalTo: shardView.trailingAnchor, constant: -10),
                   hStackView.topAnchor.constraint(equalTo: shardLabel.bottomAnchor, constant: 5),
               ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with props: CaosProps) {
        if let title = props.string("title") { shardLabel.text = title }
    }

    public func showLoading() { shimmer.startShimmer() }
    public func hideLoading() { shimmer.stopShimmer() }

    func setupGesture() {
        let tapSimulador = UITapGestureRecognizer(target: self, action: #selector(handleTapSimulador))
        cardViewSimulador.addGestureRecognizer(tapSimulador)
        
        let tapPix = UITapGestureRecognizer(target: self, action: #selector(handleTapPix))
        cardViewPix.addGestureRecognizer(tapPix)
        
        let tapAntecipacao = UITapGestureRecognizer(target: self, action: #selector(handleTapAntecipacao))
        cardViewAnticipation.addGestureRecognizer(tapAntecipacao)
        
        let tapCancelamento = UITapGestureRecognizer(target: self, action: #selector(handleTapCancelamento))
        cardViewPCancellation.addGestureRecognizer(tapCancelamento)
    }
    
    
    @objc func handleTapSimulador() {
        delegate?.didTapCardView(context: "simulator")
    }
    
    @objc func handleTapPix() {
        delegate?.didTapCardView(context: "pix")
    }
    
    @objc func handleTapAntecipacao() {
        delegate?.didTapCardView(context: "antecipacao")
    }
    
    @objc func handleTapCancelamento() {
        delegate?.didTapCardView(context: "cancelamento")
    }

}
