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
    var colorButton: Color
    var colorText: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                    .fontWeight(.bold)
                    .foregroundColor(colorText)
                    .multilineTextAlignment(.center)
                if loading {
                    ProgressView()
                        .padding(.leading, 6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Spacer()
            }
        }
        .disabled(loading)
        .padding()
        .background(colorButton)
        .cornerRadius(8)
    }
}

struct ImageButton: View {
    
    var action: () -> Void
    var countPhoto: [Data]
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.rosenergo.opacity(0.2))
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 72, idealHeight: 72, maxHeight: 72)
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
            }
        }
    }
}

struct MenuButton: View {
    
    var title: String
    var image: String
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
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
        }
    }
}

