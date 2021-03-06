//
//  DownloadIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct DownloadIndicator: ViewModifier {
    @Binding var fileType: FileType?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            if let type = fileType {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Загрузка \(type == .photo ? "фотографий" : "видео")")
                            .fontWeight(.bold)
                        Text("Пожалуйста, подождите")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                .padding()
                .background(Color.rosenergo)
                .cornerRadius(8)
                .zIndex(1)
                .padding(.horizontal)
                .animation(.easeInOut)
                .transition(
                    AnyTransition
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                )
            }
            content
        }
    }
}

struct DownloadIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Text("DownloadIndicator")
            .downloadIndicator(fileType: .constant(.photo))
    }
}

extension View {
    func downloadIndicator(fileType: Binding<FileType?>) -> some View {
        modifier(DownloadIndicator(fileType: fileType))
    }
}
