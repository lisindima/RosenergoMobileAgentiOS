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
        setting
        #else
        setting
            .environment(\.horizontalSizeClass, .regular)
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
    
    var setting: some View {
        Form {
            Section(header: Text("Личные данные").fontWeight(.bold)) {
                SectionItem(
                    imageName: "person",
                    imageColor: .rosenergo,
                    subTitle: "Агент",
                    title: sessionStore.loginModel?.data.name ?? "Ошибка"
                )
                SectionItem(
                    imageName: "envelope",
                    imageColor: .rosenergo,
                    subTitle: "Эл.почта",
                    title: sessionStore.loginModel?.data.email ?? "Ошибка"
                )
            }
            #if !os(watchOS)
            Section(header: Text("Уведомления").fontWeight(.bold), footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Выключить уведомления", titleColor: .primary) {
                        self.openSettings()
                    }
                    Stepper(value: $notificationStore.notifyHour, in: 1...24) {
                        Image(systemName: "timer")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Text("\(notificationStore.notifyHour) ч.")
                    }
                }
                if notificationStore.enabled == .notDetermined {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Включить уведомления", titleColor: .primary) {
                        self.notificationStore.requestPermission()
                    }
                }
                if notificationStore.enabled == .denied {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Включить уведомления", titleColor: .primary) {
                        self.openSettings()
                    }
                }
            }
            Section(header: Text("Другое").fontWeight(.bold), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
                SectionButton(imageName: "ant", imageColor: .rosenergo, title: "Сообщить об ошибке", titleColor: .primary) {
                    if MFMailComposeViewController.canSendMail() {
                        self.showMailView()
                    } else {
                        SPAlert.present(title: "Не установлено приложение \"Почта\".", message: "Установите его из App Store." , preset: .error)
                    }
                }
            }
            #endif
            Section {
                SectionButton(imageName: "flame", imageColor: .red, title: "Выйти", titleColor: .red) {
                    self.showActionSheetExit = true
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
