//
//  ServerImage.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 18.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct ServerImage: View {
    var path: URL
    var delay: TimeInterval = 0.0
    
    init(_ path: URL, delay: TimeInterval) {
        self.path = path
        self.delay = delay
    }
    
    var scale: CGFloat {
        #if os(watchOS)
        return WKInterfaceDevice.current().screenScale
        #else
        return UIScreen.main.scale
        #endif
    }
    
    var size: CGFloat {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        URLImage(
            path,
            delay: delay,
            processors: [Resize(size: CGSize(width: size, height: size), scale: scale)],
            placeholder: { _ in
                ProgressView()
            }
        ) {
            $0.image
                .resizable()
        }
        .cornerRadius(8)
        .frame(width: size, height: size)
    }
}
