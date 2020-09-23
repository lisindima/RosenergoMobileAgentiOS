//
//  LoadingView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LoadingView<Value, Content>: View where Content: View {
    var loadingState: LoadingState<Value>
    var title: String = ""
    var subTitle: String = ""
    var content: (_ value: Value) -> Content

    init(_ loadingState: LoadingState<Value>, content: @escaping (_ value: Value) -> Content) {
        self.loadingState = loadingState
        self.content = content
    }
    
    init(_ loadingState: LoadingState<Value>, title: String, subTitle: String, content: @escaping (_ value: Value) -> Content) {
        self.loadingState = loadingState
        self.title = title
        self.subTitle = subTitle
        self.content = content
    }
    
    var body: some View {
        switch loadingState {
        case .loading:
            ProgressView("Загрузка")
        case let .success(value):
            content(value)
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
            CustomButton("Повторить") {}
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
