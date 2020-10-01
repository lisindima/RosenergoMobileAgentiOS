//
//  DownloadIndicator.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 11.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct DownloadIndicator: View {
    var fileType: FileType
    
    var body: some View {
        HStack {
            ProgressView()
            Text("Загрузка \(fileType == .photo ? "фотографий" : "видео")")
                .padding(.leading, 8)
        }
    }
}
