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
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
                    .opacity(0.2)
                    .frame(maxWidth: .infinity, maxHeight: 70)
                VStack {
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .foregroundColor(.rosenergo)
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
