//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: ListInspections()) {
                Text("Осмотры")
                    .bold()
                    .foregroundColor(.purple)
                    .padding(50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.purple.opacity(0.2))
                )
            }.navigationBarTitle("Мобильный агент")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
