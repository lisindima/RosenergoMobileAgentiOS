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
    var colorButton: Color = .rosenergo
    var colorText: Color = .white
    var action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    init(_ title: String, loading: Bool, action: @escaping () -> Void) {
        self.title = title
        self.loading = loading
        self.action = action
    }
    
    init(_ title: String, loading: Bool, progress: Double, action: @escaping () -> Void) {
        self.title = title
        self.loading = loading
        self.progress = progress
        self.action = action
    }
    
    init(_ title: String, subTitle: String, loading: Bool, progress: Double, action: @escaping () -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.loading = loading
        self.progress = progress
        self.action = action
    }
    
    init(_ title: String, subTitle: String, colorButton: Color, colorText: Color, action: @escaping () -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.colorButton = colorButton
        self.colorText = colorText
        self.action = action
    }
    
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
        .background(colorButton)
        .cornerRadius(8)
    }
}
