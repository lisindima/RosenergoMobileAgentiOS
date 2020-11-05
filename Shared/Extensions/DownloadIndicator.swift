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
        ZStack {
            if fileType != nil {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Загрузка \(fileType == .photo ? "фотографий" : "видео")")
                                .fontWeight(.bold)
                            Text("Нажмите, чтобы отменить.")
                                .font(.caption)
                        }
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .zIndex(1)
                .padding(.horizontal)
                .animation(.easeInOut)
                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        fileType = nil
                    }
                }
            }
            content
        }
    }
}

extension View {
    func downloadIndicator(fileType: Binding<FileType?>) -> some View {
        modifier(DownloadIndicator(fileType: fileType))
    }
}
