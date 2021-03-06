//
//  Haptic.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

func playHaptic(_ type: HapticType) {
    switch type {
    case .error:
        #if os(watchOS)
        playNotificationWatchHaptic(.retry)
        #elseif os(iOS)
        playNotificationHaptic(.error)
        #else
        break
        #endif
    case .success:
        #if os(watchOS)
        playNotificationWatchHaptic(.success)
        #elseif os(iOS)
        playNotificationHaptic(.success)
        #else
        break
        #endif
    case .warning:
        #if os(watchOS)
        playNotificationWatchHaptic(.failure)
        #elseif os(iOS)
        playNotificationHaptic(.warning)
        #else
        break
        #endif
    }
}

#if os(watchOS)
func playNotificationWatchHaptic(_ type: WKHapticType) {
    WKInterfaceDevice.current().play(type)
}

#elseif os(iOS)
func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}
#endif
