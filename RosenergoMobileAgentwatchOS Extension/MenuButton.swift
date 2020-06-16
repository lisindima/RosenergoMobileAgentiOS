//
//  MenuButton.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuButton: View {
    
    var title: String
    var image: String
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: 120)
            VStack {
                Image(systemName: image)
                    .imageScale(.large)
                    .foregroundColor(color)
                    .padding(.top, 8)
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
