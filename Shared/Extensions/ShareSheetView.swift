//
//  ShareSheet.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 03.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

#if os(iOS)
struct ShareSheetView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context _: UIViewControllerRepresentableContext<ShareSheetView>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ShareSheetView>) {}
}
#endif

struct ShareSheet: ViewModifier {
    @Binding var item: ShareSheetItem?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        content
            .sheet(item: $item) { item in
                ShareSheetView(activityItems: item.activityItems)
                    .ignoresSafeArea(edges: .bottom)
            }
        #endif
    }
}

extension View {
    func shareSheet(item: Binding<ShareSheetItem?>) -> some View {
        modifier(ShareSheet(item: item))
    }
}

struct ShareSheetItem: Identifiable {
    var id = UUID()
    var activityItems: [Any]
}
