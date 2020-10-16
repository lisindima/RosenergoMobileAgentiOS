//
//  ServerImage.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 18.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if os(iOS)
import URLImage
#endif

struct ServerImage: View {
    var path: URL
    var isFullScreen: Bool = false
    var delay: TimeInterval = 0.0
    
    init(_ path: URL, isFullScreen: Bool) {
        self.path = path
        self.isFullScreen = isFullScreen
    }
    
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
    
    #if os(iOS)
    var image: some View {
        URLImage(
            url: path,
            options: URLImageOptions(cachePolicy: .returnCacheElseLoad(cacheDelay: nil, downloadDelay: delay)),
            inProgress: { progress in
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle())
            },
            failure: { error, retry in
                Button(action: retry) {
                    Image(systemName: "arrow.clockwise.circle")
                        .imageScale(.large)
                }
            }
        ) { image in
            image
                .resizable()
        }
    }
    #endif
    
    var body: some View {
        #if os(iOS)
        if isFullScreen {
            image
        } else {
            image
                .cornerRadius(8)
                .frame(width: size, height: size)
        }
        #endif
    }
}
