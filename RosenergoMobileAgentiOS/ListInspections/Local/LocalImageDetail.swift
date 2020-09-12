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
    var photos: [LocalPhotos]
    
    var body: some View {
        TabView(selection: $selectionImage) {
            ForEach(photos, id: \.id) { photo in
                Image(uiImage: UIImage(data: photo.photosData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .pinchToZoom()
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .modifier(TabViewBackgroundMode())
        .navigationTitle("\(selectionImage) из \(photos.last!.id)")
        .onAppear { selectionImage = id }
    }
}
