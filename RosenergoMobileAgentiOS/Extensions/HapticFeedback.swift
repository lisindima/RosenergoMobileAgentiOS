//
//  HapticFeedback.swift
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
}
