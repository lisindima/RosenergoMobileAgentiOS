//
//  ResizedImage.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 03.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        #else
        return self
        #endif
    }
}
