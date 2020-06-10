//
//  NotificationStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import UserNotifications

class NotificationStore: ObservableObject {
    
    @Published var enabled: UNAuthorizationStatus = .notDetermined
    
    static let shared = NotificationStore()
    
    var notifications = [Notification]()
    var center: UNUserNotificationCenter = .current()
    
    init() {
        center.getNotificationSettings {
            self.enabled = $0.authorizationStatus
        }
    }
    
    func refreshNotificationStatus() {
        center.getNotificationSettings { setting in
            DispatchQueue.main.async {
                self.enabled = setting.authorizationStatus
            }
        }
    }
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.enabled = .authorized
                } else {
                    self.enabled = .denied
                }
            }
        }
    }
    
    func setNotification(id: String) {
        let manager = NotificationStore()
        manager.addNotification(id: id, title: "Отправьте сохраненый осмотр.", body: "Вы забыли отправить сохраненый осмотр на сервер!")
        manager.schedule()
    }
    
    func addNotification(id: String, title: String, body: String) {
        notifications.append(Notification(id: id, title: title, body: body))
    }
    
    func scheduleNotifications() {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.badge = 1
            content.sound = .default
            content.title = notification.title
            content.body = notification.body
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Уведомление создано: \(notification.id)")
            }
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    
    func cancelNotifications(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

struct Notification: Identifiable {
    var id: String
    var title: String
    var body: String
}
