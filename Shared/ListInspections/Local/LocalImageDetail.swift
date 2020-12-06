//
//  LocalImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocalImageDetail: View {
    @State private var selectionImage: Int = 1
    
    var id: Int
    var photos: Set<LocalPhotos>
    
    var body: some View {
        TabView(selection: $selectionImage) {
            ForEach(Array(photos.enumerated()), id: \.offset) { photo in
                #if os(macOS)
                Image(nsImage: NSImage(data: photo.element.photosData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #else
                Image(uiImage: UIImage(data: photo.element.photosData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .pinchToZoom()
                #endif
            }
        }
//        .tabViewStyle(PageTabViewStyle())
        .modifier(TabViewBackgroundMode())
        .navigationTitle("\(selectionImage) из \(Array(photos).last!.id)")
        .modifier(InlineTitleDisplayMode())
        .onAppear { selectionImage = id }
    }
}
