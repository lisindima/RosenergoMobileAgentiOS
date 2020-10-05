//
//  SettingsView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var notificationStore: NotificationStore = NotificationStore.shared
    
    @State private var showActionSheetExit: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMailType: AlertMailType = .sent
    
    private func showMailView() {
        DispatchQueue.main.async {
            let mailFeedback = UIHostingController(rootView:
                MailFeedback(showAlert: $showAlert, alertMailType: $alertMailType)
                    .edgesIgnoringSafeArea(.bottom)
                    .accentColor(.rosenergo)
            )
            UIApplication.shared.windows.first?.rootViewController?.present(
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
            return Text("Укажите, через какое время вам придет уведомление после сохранённого осмотра.")
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
                        Button("Выключить уведомления", action: openSettings)
                            .foregroundColor(.primary)
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
                        Button("Включить уведомления", action: notificationStore.requestPermission)
                            .foregroundColor(.primary)
                    }
                }
                if notificationStore.enabled == .denied {
                    HStack {
                        Image(systemName: "bell")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Включить уведомления", action: openSettings)
                            .foregroundColor(.primary)
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
                            showMailView()
                        } else {
                            alertMailType = .error
                            showAlert = true
                        }
                    }.foregroundColor(.primary)
                }
            }
            Section {
                Button(action:  {
                    showActionSheetExit = true
                }) {
                    HStack {
                        Image(systemName: "flame")
                            .frame(width: 24)
                        Text("Выйти из аккаунта")
                    }.foregroundColor(.red)
                }
            }.actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    presentationMode.wrappedValue.dismiss()
                    sessionStore.logout()
                    }, .cancel()
                ])
            }
        }
        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitle("Настройки")
        .alert(isPresented: $showAlert) {
            switch alertMailType {
            case .sent:
                return Alert(title: Text("Сообщение отправлено"), message: Text("Я отвечу на него в ближайшее время."), dismissButton: .default(Text("Закрыть")))
            case .saved:
                return Alert(title: Text("Сообщение сохранено"), message: Text("Сообщение ждет вас в черновиках."), dismissButton: .default(Text("Закрыть")))
            case .failed:
                return Alert(title: Text("Ошибка"), message: Text("Повторите попытку позже."), dismissButton: .default(Text("Закрыть")))
            case .error:
                return Alert(title: Text("Не установлено приложение \"Почта\""), message: Text("Для отправки сообщений об ошибках вам понадобится официальное приложение \"Почта\", установите его из App Store."), dismissButton: .default(Text("Закрыть")))
            }
        }
    }
}
