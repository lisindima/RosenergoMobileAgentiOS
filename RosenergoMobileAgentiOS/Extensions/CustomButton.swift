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
                    ActivityIndicatorButton()
                }
                Spacer()
            }
        }
        .padding()
        .background(colorButton)
        .cornerRadius(8)
        .hoverEffect(.highlight)
    }
}

struct ImageButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.rosenergo)
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: 53, idealHeight: 53, maxHeight: 53)
                VStack {
                    Image(systemName: "camera")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ActivityIndicatorButton: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorButton>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.color = .white
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorButton>) {
        
    }
}
