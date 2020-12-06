//
//  LocalImage.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 01.10.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalImage: View {
    var data: Data
    
    var size: CGFloat {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        #if os(macOS)
        Image(nsImage: NSImage(data: data)!)
            .resizable()
            .cornerRadius(8)
            .frame(width: size, height: size)
        #else
        Image(uiImage: UIImage(data: data)!.resizedImage(width: size, height: size))
            .resizable()
            .cornerRadius(8)
            .frame(width: size, height: size)
        #endif
    }
}
