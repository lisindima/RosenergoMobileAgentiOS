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
    var loading: Bool?
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
                if loading ?? false {
                    ProgressView()
                        .padding(.horizontal, 6)
                }
                Spacer()
            }
        }
        .padding()
        .background(colorButton)
        .cornerRadius(8)
        //.hoverEffect(.highlight)
    }
}

struct ImageButton: View {
    
    var action: () -> Void
    var photoParameters: [PhotoParameters]
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.rosenergo.opacity(0.2))
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 72, idealHeight: 72, maxHeight: 72)
                VStack {
                    if photoParameters.count == 0 {
                        Image(systemName: "camera")
                            .font(.title)
                            .foregroundColor(.rosenergo)
                    } else {
                        Text("Фотографий добавлено: \(photoParameters.count)")
                            .fontWeight(.bold)
                            .foregroundColor(.rosenergo)
                    }
                }
            }
        }
    }
}
