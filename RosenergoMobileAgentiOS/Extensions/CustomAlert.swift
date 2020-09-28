//
//  CustomAlert.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String
    var action: (() -> Void)? = {}
}

struct CustomAlert: ViewModifier {
    @Binding var item: AlertItem?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $item) { item in
                playHaptic(item.title == "Ошибка" ? .error : .success)
                return alert(title: item.title, message: item.message, action: item.action)
            }
    }
}

extension ViewModifier {
    func alert(title: String, message: String, action: (() -> Void)? = {}) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("Закрыть"), action: action)
        )
    }
}

extension View {
    func customAlert(item: Binding<AlertItem?>) -> some View {
        modifier(CustomAlert(item: item))
    }
}
