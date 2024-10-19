//
//  CaosParser.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

import Foundation

class CaosParser {
    
    //MARK: - Properties
    
    private var screens: [CaosScreen] = []

    //MARK: - Initializer
    
    init(content: String){
        self.readConfig(content: content)
    }
    
    //MARK: - Private Methods
    
    private func readConfig(content: String) {
        
        let lines = content.components(separatedBy: "\n")
        var screen: CaosScreen?

        for (index, line) in lines.enumerated() {
            if line.contains("container") {
                screen = CaosScreen()
                screen?.container = getValue(line: line)
            }

            if line.contains("shard") {
                screen?.shards.append(getValue(line: line))
            }

            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || index == lines.count - 1 {
                if let scr = screen {
                    screens.append(scr)
                    screen = nil  // reset the screen
                }
            }
        }
    }
    
    private func getValue(line: String) -> String {
        let value = line.components(separatedBy: ":")
        
        if value.count > 1 {
            return value[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return ""
    }
    
    //MARK: - Public Methods

    func getScreens() -> [CaosScreen] {
        return screens
    }
    
}

