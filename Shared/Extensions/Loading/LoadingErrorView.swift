//
//  LoadingErrorView.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 12.10.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LoadingErrorView: View {
    var error: Error
    var retryHandler: () -> Void
    
    var body: some View {
        Spacer()
        Text("Произошла ошибка")
            .messageTitle()
            .multilineTextAlignment(.center)
            .padding(.bottom)
        Text(error.localizedDescription)
            .messageSubtitle()
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        Spacer()
        CustomButton("Повторить", action: retryHandler)
            .padding()
    }
}
