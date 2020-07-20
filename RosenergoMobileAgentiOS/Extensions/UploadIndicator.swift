//
//  UploadIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 05.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct UploadIndicator: View {
    
    @Binding var progress: Double
    var color: Color
    
    var body: some View {
        Group {
            if progress == 1.0 {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                }
                .padding()
                .background(Color.rosenergo)
                .cornerRadius(8)
            } else {
                ZStack {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 53)
                                .cornerRadius(8)
                                .foregroundColor(color)
                                .opacity(0.2)
                            Rectangle()
                                .frame(width: CGFloat(progress) * geometry.size.width, height: 53)
                                .cornerRadius(8)
                                .foregroundColor(color)
                                .animation(.linear)
                            HStack {
                                Spacer()
                                Text("\(Int(progress * 100)) %")
                                    .foregroundColor(.white)
                                    .font(.custom("Futura", size: 24))
                                Spacer()
                            }
                        }
                    }
                }
            }
        }.frame(height: 53)
    }
}
