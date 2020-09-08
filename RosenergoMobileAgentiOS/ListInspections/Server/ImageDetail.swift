//
//  ImageDetail.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 24.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage

struct ImageDetail: View {
    @State private var selectionImage: Int = 1

    var id: Int
    var photos: [Photo]

    var body: some View {
        TabView(selection: $selectionImage) {
            ForEach(photos, id: \.id) { photo in
                URLImage(
                    photo.path,
                    placeholder: { _ in
                        ProgressView()
                    }
                ) {
                    $0.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationTitle("\(selectionImage) из \(photos.last!.id)")
        .onAppear { selectionImage = id }
    }
}
