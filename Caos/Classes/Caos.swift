//
//  Caos.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

import Foundation

public class Caos {
    
    //MARK: - static method
    
    public static func configure(bundle: Bundle, name:String, target: CaosEngineDelegate) -> CaosEngine? {
        
        guard let path = bundle.path(forResource: name, ofType: "yaml") else {
            fatalError("Caos.bundle not found")
        }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return  CaosEngine(content: content, target: target)
        } catch {
            print("Erro ao ler o arquivo: \(error.localizedDescription)")
            return nil
        }
        
    }
    
}
