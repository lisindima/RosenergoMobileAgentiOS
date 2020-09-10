//
//  View.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

extension View {
    func playHaptic(_ type: HapticType) {
        switch type {
        case .error:
            #if os(watchOS)
            playNotificationWatchHaptic(.retry)
            #else
            playNotificationHaptic(.error)
            #endif
        case .success:
            #if os(watchOS)
            playNotificationWatchHaptic(.success)
            #else
            playNotificationHaptic(.success)
            #endif
        case .warning:
            #if os(watchOS)
            playNotificationWatchHaptic(.failure)
            #else
            playNotificationHaptic(.warning)
            #endif
        }
    }
    #if os(watchOS)
    func playNotificationWatchHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    #else
    func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    #endif
    
    func customAlert(_ alertItem: Binding<AlertItem?>) -> some View {
        modifier(CustomAlert(alertItem: alertItem))
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

struct CustomAlert: ViewModifier {
    @Binding var alertItem: AlertItem?
    
    func body(content: Content) -> some View {
        content
            .alert(item: $alertItem) { item in
                alert(title: item.title, message: item.message, action: item.action)
            }
    }
}
