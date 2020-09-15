//
//  ImageButton.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 15.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ImageButton: View {
    var countPhoto: [URL]
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                if countPhoto.isEmpty {
                    Image(systemName: "camera")
                        .font(.title)
                        .foregroundColor(.rosenergo)
                } else {
                    Text("Фотографий добавлено: \(countPhoto.count)")
                        .fontWeight(.bold)
                        .foregroundColor(.rosenergo)
                }
            }
            .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 60, idealHeight: 60, maxHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.rosenergo.opacity(0.2))
            )
        }
    }
}
