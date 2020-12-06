//
//  ExitButton.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 06.12.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ExitButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .font(Font.body.weight(.bold))
                    .scaleEffect(0.416)
                    .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
            }
        }.frame(width: 24, height: 24)
    }
}
