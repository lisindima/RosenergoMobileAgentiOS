//
//  CustomInput.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct InputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color.secondary.opacity(0.1))
            )
    }
}

struct CustomInput: View {
    @Binding var text: String
    var name: String
    
    var body: some View {
        TextField(name, text: $text)
            .modifier(InputModifier())
    }
}
