//
//  Caos.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

#if canImport(UIKit)
import Foundation

public class Caos {

    // MARK: - v1 API — with CaosStore

    public static func configure(
        bundle: Bundle,
        name: String,
        target: CaosEngineDelegate,
        store: CaosStore? = nil
    ) -> CaosEngine? {
        guard let path = bundle.path(forResource: name, ofType: "yaml") else {
            fatalError("Caos: '\(name).yaml' not found in bundle")
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return CaosEngine(content: content, target: target, store: store)
        } catch {
            print("Caos: error reading '\(name).yaml': \(error.localizedDescription)")
            return nil
        }
    }
}
#endif
