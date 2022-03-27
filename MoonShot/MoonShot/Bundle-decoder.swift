//
//  Bundle-decoder.swift
//  MoonShot
//
//  Created by Arseniy Matus on 27.03.2022.
//

import Foundation


extension Bundle {
    func decode<T: Codable> (_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file)")
        }
        
        guard let data  = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file)")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-DD"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Could not decode \(file)")
        }
        
        return loaded
    }
}
