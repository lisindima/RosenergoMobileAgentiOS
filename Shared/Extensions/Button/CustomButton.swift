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
    var titleUpload: String = "Загрузка"
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
    
    init(_ title: String, titleUpload: String, loading: Bool, progress: Double, action: @escaping () -> Void) {
        self.title = title
        self.titleUpload = titleUpload
        self.loading = loading
        self.progress = progress
        self.action = action
    }
    
    init(_ title: String, colorButton: Color, colorText: Color, action: @escaping () -> Void) {
        self.title = title
        self.colorButton = colorButton
        self.colorText = colorText
        self.action = action
    }
    
    var body: some View {
        #if os(iOS)
        phone
        #else
        watch
        #endif
    }
    
    var watch: some View {
        Button(action: action) {
            if loading {
                ProgressView()
            } else {
                Text(title)
            }
        }
    }
    
    var phone: some View {
        Button(action: action) {
            if loading, progress != 0.0 {
                ProgressView(
                    value: progress,
                    label: { Text(titleUpload).foregroundColor(.rosenergo).fontWeight(.bold) },
                    currentValueLabel: { Text("\(Int(progress * 100)) %") }
                )
                .padding(8)
            } else {
                HStack {
                    Spacer()
                    if loading, progress == 0.0 {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: colorText))
                            .padding(.trailing, 3)
                    }
                    Text(loading ? "Загрузка" : title)
                        .fontWeight(.bold)
                        .foregroundColor(colorText)
                    Spacer()
                }.padding()
            }
        }
        .disabled(loading)
        .background(progress == 0.0 ? colorButton : colorButton.opacity(0.2))
        .cornerRadius(8)
    }
}
