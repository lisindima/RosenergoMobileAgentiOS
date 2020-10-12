//
//  LoadingEmptyView.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 12.10.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LoadingEmptyView: View {
    var title: String
    var subTitle: String
    
    var body: some View {
        Text(title)
            .messageTitle()
            .multilineTextAlignment(.center)
            .padding(.bottom)
        Text(subTitle)
            .messageSubtitle()
            .multilineTextAlignment(.center)
    }
}
