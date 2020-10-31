//
//  ImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 24.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ImageDetail: View {
    @State private var selectionImage: Int = 1
    
    var id: Int
    var photos: [Photo]
    
    var body: some View {
        TabView(selection: $selectionImage) {
            ForEach(photos, id: \.id) { photo in
                FullScreenServerImage(photo.path)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .modifier(TabViewBackgroundMode())
        .navigationTitle("\(selectionImage) из \(photos.last!.id)")
        .modifier(InlineTitleDisplayMode())
        .onAppear { selectionImage = id }
    }
}
