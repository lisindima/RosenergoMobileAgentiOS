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
    var load: () -> Void
    var title: String = ""
    var subTitle: String = ""
    var content: (_ value: Value) -> Content

    init(_ loadingState: LoadingState<Value>, load: @escaping () -> Void, content: @escaping (_ value: Value) -> Content) {
        self.loadingState = loadingState
        self.load = load
        self.content = content
    }
    
    init(_ loadingState: LoadingState<Value>, load: @escaping () -> Void, title: String, subTitle: String, content: @escaping (_ value: Value) -> Content) {
        self.loadingState = loadingState
        self.load = load
        self.title = title
        self.subTitle = subTitle
        self.content = content
    }
    
    var body: some View {
        switch loadingState {
        case .loading:
            ProgressView("Загрузка")
                .onAppear(perform: load)
        case let .success(value):
            content(value)
                .onAppear(perform: load)
        case let .failure(error):
            Spacer()
            Text("Произошла ошибка")
                .errorTitle()
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Text(error.localizedDescription)
                .errorSubtitle()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            CustomButton("Повторить", action: load)
            .padding()
        case .empty:
            Group {
                Text(title)
                    .errorTitle()
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Text(subTitle)
                    .errorSubtitle()
                    .multilineTextAlignment(.center)
            }
            .onAppear(perform: load)
        }
    }
}
