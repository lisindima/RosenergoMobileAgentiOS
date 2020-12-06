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
    
    var size: CGFloat {
        #if os(watchOS)
        return 75.0
        #else
        return 100.0
        #endif
    }
    
    var body: some View {
        URLImage(
            url: path,
            options: URLImageOptions(
                cachePolicy: .returnCacheElseLoad(cacheDelay: nil, downloadDelay: delay),
                maxPixelSize: CGSize(width: 300, height: 300)
            ),
            inProgress: { progress in
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle())
            },
            failure: { _, retry in
                Button(action: retry) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.largeTitle)
                }
            }
        ) { image in
            image
                .resizable()
        }
        .cornerRadius(8)
        .frame(width: size, height: size)
    }
}

struct FullScreenServerImage: View {
    var path: URL
    
    init(_ path: URL) {
        self.path = path
    }
    
    var body: some View {
        URLImage(
            url: path,
            options: URLImageOptions(
                maxPixelSize: CGSize(width: 3000, height: 3000)
            ),
            inProgress: { progress in
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle())
            },
            failure: { _, retry in
                Button(action: retry) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.largeTitle)
                }
            }
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .pinchToZoom()
        }
    }
}
