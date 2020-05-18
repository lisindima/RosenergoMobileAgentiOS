//
//  LocationView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 18.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LocationView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color.red.opacity(0.2))
        )
    }
}
