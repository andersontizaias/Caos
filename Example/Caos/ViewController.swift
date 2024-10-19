//
//  ViewController.swift
//  Caos
//
//  Created by andersontizaias on 10/07/2023.
//  Copyright (c) 2023 andersontizaias. All rights reserved.
//

import UIKit
import Caos

class ViewController: UIViewController, CaosEngineDelegate  {
    
    //MARK: - Properties
    
    var rootView: UIView {
        return self.view
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootView(caosScreen: getScreen(engine: setupCaos()))
        self.view.layoutIfNeeded()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private methods
    
    private func setupCaos()-> CaosEngine? {
        return Caos.configure(bundle: Bundle.main, name: "caos", target: self)
    }
    
    private func getScreen(engine: CaosEngine?) -> UIView {
         return engine?.getScreenByIndex(index: 0) ?? UIView()
    }
    
    private func setupRootView(caosScreen: UIView){
        self.view.addSubview(caosScreen)
        
        NSLayoutConstraint.activate([
            caosScreen.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            caosScreen.bottomAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.bottomAnchor),
            caosScreen.leadingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.leadingAnchor),
            caosScreen.trailingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    private func getIntRandom() -> Int {
        return Int.random(in: 0..<6)
    }
    
    // MARK: - CaosEngineDelegate
    
    func didTapCardView(context: String) {
        print("Tocando na view do card \(context)")
    }
    
    func requestDataForLabel() -> String {
        return "R$30.000,00"
    }
    
}

