//
//  Bundle.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 28.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Foundation

extension Bundle {
    func decode(_ file: String) -> [LicenseModel] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let loaded = try? decoder.decode([LicenseModel].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        
        return loaded
    }
}
