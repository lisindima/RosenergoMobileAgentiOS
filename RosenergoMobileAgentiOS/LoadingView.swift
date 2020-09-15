//
//  LoadingView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LoadingView<Content: View>: View {
    var loadingState: LoadingState
    var title: String = ""
    var subTitle: String = ""
    var content: () -> Content

    init(_ loadingState: LoadingState, content: @escaping () -> Content) {
        self.loadingState = loadingState
        self.content = content
    }
    
    init(_ loadingState: LoadingState, title: String, subTitle: String, content: @escaping () -> Content) {
        self.loadingState = loadingState
        self.title = title
        self.subTitle = subTitle
        self.content = content
    }
    
    var body: some View {
        switch loadingState {
        case .loading:
            ProgressView("Загрузка")
        case .success:
            content()
        case let .failure(error):
            Spacer()
            Text("Произошла ошибка!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            CustomButton(title: "Повторить", colorButton: .rosenergo, colorText: .white) {
                
            }
            .padding()
        case .empty:
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Text(subTitle)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}