//
//  CustomButton.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CustomButton: View {
    var title: String
    var subTitle: String = ""
    var loading: Bool = false
    var progress: Double = 0.0
    var colorButton: Color
    var colorText: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if loading, progress != 0.0 {
                ProgressView(
                    value: progress,
                    label: { Text("Загрузка").foregroundColor(.rosenergo).fontWeight(.bold) },
                    currentValueLabel: { Text("\(Int(progress * 100)) %") }
                )
                .padding(8)
            } else {
                if !subTitle.isEmpty {
                    HStack {
                        Spacer()
                        VStack {
                            Text(loading ? "Загрузка" : title)
                                .fontWeight(.bold)
                                .foregroundColor(colorText)
                            Text(subTitle)
                                .font(.footnote)
                                .foregroundColor(colorText)
                        }
                        Spacer()
                    }
                    .padding(10)
                } else {
                    HStack {
                        Spacer()
                        if loading, progress == 0.0 {
                            ProgressView()
                                .padding(.trailing, 3)
                                .progressViewStyle(CircularProgressViewStyle(tint: colorText))
                        }
                        Text(loading ? "Загрузка" : title)
                            .fontWeight(.bold)
                            .foregroundColor(colorText)
                        Spacer()
                    }.padding()
                }
            }
        }
        .disabled(loading)
        .background(progress != 0.0 ? colorButton : colorButton.opacity(0.2))
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
            .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 60, idealHeight: 60, maxHeight: 60)
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
