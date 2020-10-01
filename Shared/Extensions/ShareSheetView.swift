//
//  ShareSheet.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 03.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context _: UIViewControllerRepresentableContext<ShareSheetView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ShareSheetView>) {}
}

struct ShareSheet: ViewModifier {
    @Binding var item: ShareSheetItem?
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                ShareSheetView(activityItems: item.activityItems)
                    .ignoresSafeArea(edges: .bottom)
            }
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
