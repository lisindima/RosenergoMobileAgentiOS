//
//  NotificationView.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 02.11.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject private var notificationStore: NotificationStore
    
    #if os(iOS)
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)
    #else
    private let settingsURL = URL(string: "https://apple.com")
    #endif
    
    @ViewBuilder var footerNotification: some View {
        switch notificationStore.enabled {
        case .denied:
            Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\", после чего активируйте уведомления в настройках.")
        case .notDetermined:
            Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\".")
        case .authorized:
            #if os(iOS)
            Text("Укажите, через какое время вам придет уведомление после сохранённого осмотра.")
            #endif
        default:
            Text("")
        }
    }
    
    var body: some View {
        Form {
            Section(footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    SectionLink(
                        imageName: "bell",
                        title: "Выключить уведомления",
                        url: settingsURL
                    )
                    #if os(iOS)
                    Stepper(value: $notificationStore.notifyHour, in: 1 ... 24) {
                        Image(systemName: "timer")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Text("\(notificationStore.notifyHour) ч.")
                    }
                    #endif
                } else if notificationStore.enabled == .notDetermined {
                    SectionButton(
                        imageName: "bell",
                        title: "Включить уведомления",
                        action: notificationStore.requestPermission
                    )
                } else if notificationStore.enabled == .denied {
                    SectionLink(
                        imageName: "bell",
                        title: "Включить уведомления",
                        url: settingsURL
                    )
                }
            }
        }
        .navigationTitle("Уведомления")
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
