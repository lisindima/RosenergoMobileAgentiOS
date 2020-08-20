//
//  CustomButton.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CustomButton: View {
    var label: String
    var loading: Bool = false
    var progress: Double = 0.0
    var colorButton: Color
    var colorText: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if loading, progress != 0.0 {
                    ProgressView(value: progress)
                } else {
                    Spacer()
                    if loading, progress == 0.0 {
                        ProgressView()
                            .padding(.trailing, 3)
                            .progressViewStyle(CircularProgressViewStyle(tint: colorText))
                    }
                    Text(loading ? "Загрузка" : label)
                        .fontWeight(.bold)
                        .foregroundColor(colorText)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
        }
        .disabled(loading)
        .padding()
        .background(loading ? colorButton.opacity(0.2) : colorButton)
        .cornerRadius(8)
    }
}

struct ImageButton: View {
    var action: () -> Void
    var countPhoto: [Data]

    var body: some View {
        Button(action: action) {
            VStack {
                if countPhoto.count == 0 {
                    Image(systemName: "camera")
                        .font(.title)
                        .foregroundColor(.rosenergo)
                } else {
                    Text("Фотографий добавлено: \(countPhoto.count)")
                        .fontWeight(.bold)
                        .foregroundColor(.rosenergo)
                }
            }
            .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 72, idealHeight: 72, maxHeight: 72)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.rosenergo.opacity(0.2))
            )
        }
    }
}

struct MenuButton: View {
    var title: String
    var image: String
    var color: Color
    
    var body: some View {
        VStack {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundColor(color)
                .padding(.bottom, 3)
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
        )
    }
}
