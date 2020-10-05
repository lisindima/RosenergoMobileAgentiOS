//
//  ActivityIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    var styleSpinner: UIActivityIndicatorView.Style
    
    func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: styleSpinner)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {}
}
