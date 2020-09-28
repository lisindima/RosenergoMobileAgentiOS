//
//  MenuButton.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 15.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuButton<Destination: View>: View {
    var title: String
    var image: String
    var color: Color
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
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
        }.buttonStyle(PlainButtonStyle())
    }
}
