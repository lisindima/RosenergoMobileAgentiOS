//
//  SettingsView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if !os(watchOS)
import MessageUI
import SPAlert
#endif

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    #if os(watchOS)
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    #else
    @EnvironmentObject var sessionStore: SessionStore
    @ObservedObject var notificationStore: NotificationStore = NotificationStore.shared
    #endif
    
    @State private var showActionSheetExit: Bool = false
    
    #if !os(watchOS)
    private func showMailView() {
        DispatchQueue.main.async {
            let mailFeedback = UIHostingController(rootView:
                                                    MailFeedback()
                                                    .edgesIgnoringSafeArea(.bottom)
                                                    .accentColor(.rosenergo)
            )
            UIApplication.shared.windows.first?.rootViewController?.present(
                mailFeedback, animated: true, completion: nil
            )
        }
    }
    #endif
    
    #if !os(watchOS)
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL)
        else {
            return
        }
        UIApplication.shared.open(settingsURL)
    }
    #endif
    
    @ViewBuilder var body: some View {
        #if os(watchOS)
        watchSetting
        #else
        phoneSetting
        #endif
    }
    
    #if !os(watchOS)
    var footerNotification: Text {
        switch notificationStore.enabled {
        case .denied:
            return Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\", после чего активируйте уведомления в настройках.")
        case .notDetermined:
            return Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\".")
        case .authorized:
            return Text("Укажите, через какое время вам придет уведомление после сохранённого осмотра.")
        default:
            return Text("")
        }
    }
    #endif
    
    #if !os(watchOS)
    var phoneSetting: some View {
        Form {
            Section(header: Text("Личные данные").fontWeight(.bold)) {
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
            Section(header: Text("Уведомления").fontWeight(.bold), footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Выключить уведомления") {
                            self.openSettings()
                        }.foregroundColor(.primary)
                    }
                    Stepper(value: $notificationStore.notifyHour, in: 1...24) {
                        Image(systemName: "timer")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Text("\(notificationStore.notifyHour) ч.")
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
            Section(header: Text("Другое").fontWeight(.bold), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
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
    #endif
    
    var watchSetting: some View {
        Form {
            Section(header: Text("Личные данные").fontWeight(.bold)) {
                HStack {
                    Image(systemName: "person")
                        .frame(width: 24)
                        .foregroundColor(.purple)
                    VStack(alignment: .leading) {
                        Text("Агент")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.name ?? "Ошибка")
                            .font(.footnote)
                    }
                }
                HStack {
                    Image(systemName: "envelope")
                        .frame(width: 24)
                        .foregroundColor(.purple)
                    VStack(alignment: .leading) {
                        Text("Эл.почта")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.email ?? "Ошибка")
                            .font(.footnote)
                    }
                }
            }
            Section {
                Button(action:  {
                    self.showActionSheetExit = true
                }) {
                    HStack {
                        Image(systemName: "flame")
                            .frame(width: 24)
                        Text("Выйти")
                    }.foregroundColor(.red)
                }
            }.actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    self.presentationMode.wrappedValue.dismiss()
                    self.sessionStore.logout()
                }, .cancel()
                ])
            }
        }.navigationBarTitle("Настройки")
    }
}
