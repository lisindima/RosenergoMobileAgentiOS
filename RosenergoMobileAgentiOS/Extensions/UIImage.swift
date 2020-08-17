//
//  UIImage.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 03.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

extension UIImage {
    func resizedImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        #if os(iOS)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: size))
            }
        #else
            return self
        #endif
    }

    func addText(_ text: String, point: CGPoint) -> UIImage {
        let textColor = UIColor(named: "textColor")
        let textFont = UIFont(name: "Helvetica Bold", size: 40)!
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor!,
        ] as [NSAttributedString.Key: Any]

        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let rect = CGRect(origin: point, size: size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
