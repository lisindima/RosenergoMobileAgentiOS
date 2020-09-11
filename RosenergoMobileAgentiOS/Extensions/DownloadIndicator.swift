//
//  DownloadIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct DownloadIndicator: View {
    @Binding var fileType: FileType
    
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Text("Загрузка \(fileType == .photo ? "фотографий" : "видео")")
                .padding(.leading, 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .circular)
                .fill(Color.rosenergo)
        )
    }
}
