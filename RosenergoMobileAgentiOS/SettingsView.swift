//
//  SettingsView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SPAlert
import MessageUI

struct SettingsView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var notificationStore: NotificationStore = NotificationStore.shared
    
    @State private var showActionSheetExit: Bool = false
    
    private func showMailView() {
        DispatchQueue.main.async {
            let mailFeedback = UIHostingController(rootView:
                MailFeedback()
                    .edgesIgnoringSafeArea(.bottom)
                    .accentColor(.rosenergo)
            )
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.presentedViewController?.present(
                mailFeedback, animated: true, completion: nil
            )
        }
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL)
            else {
                return
        }
        UIApplication.shared.open(settingsURL)
    }
    
    var footerNotification: Text {
        switch notificationStore.enabled {
        case .denied:
            return Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\", после чего активируйте уведомления в настройках.")
        case .notDetermined:
            return Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\".")
        case .authorized:
            return Text("Вам придет уведомление, когда вы забудете отправить сохраненный осмотр на сервер.")
        default:
            return Text("")
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Личные данные".uppercased())) {
                HStack {
                    Image(systemName: "person")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Агент")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.name ?? "Ошибка")
                    }
                }
                HStack {
                    Image(systemName: "envelope")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Эл.почта")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.email ?? "Ошибка")
                    }
                }
            }
            Section(header: Text("Уведомления".uppercased()), footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Выключить уведомления") {
                            self.openSettings()
                        }.foregroundColor(.primary)
                    }
                }
                if notificationStore.enabled == .notDetermined {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Включить уведомления") {
                            self.notificationStore.requestPermission()
                        }.foregroundColor(.primary)
                    }
                }
                if notificationStore.enabled == .denied {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Включить уведомления") {
                            self.openSettings()
                        }.foregroundColor(.primary)
                    }
                }
            }
            Section(header: Text("Другое".uppercased()), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
                HStack {
                    Image(systemName: "ant")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    Button("Сообщить об ошибке") {
                        if MFMailComposeViewController.canSendMail() {
                            self.showMailView()
                        } else {
                            SPAlert.present(title: "Не установлено приложение \"Почта\".", message: "Установите его из App Store." , preset: .error)
                        }
                    }.foregroundColor(.primary)
                }
            }
            Section {
                Button(action:  {
                    self.showActionSheetExit = true
                }) {
                    HStack {
                        Image(systemName: "flame")
                            .frame(width: 24)
                        Text("Выйти из аккаунта")
                    }.foregroundColor(.red)
                }
            }.actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    self.presentationMode.wrappedValue.dismiss()
                    self.sessionStore.logout()
                    }, .cancel()
                ])
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Настройки")
    }
}
