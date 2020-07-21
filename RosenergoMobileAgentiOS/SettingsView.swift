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
import WidgetKit
#endif

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var sessionStore: SessionStore
    
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    #endif
    
    @State private var showAlert: Bool = false
    @State private var alertMailType: AlertMailType = .sent
    @State private var showActionSheetExit: Bool = false
    
    #if !os(watchOS)
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
    
    var body: some View {
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
            if sessionStore.loginModel?.data.name != nil || sessionStore.loginModel?.data.email != nil {
                Section(header: Text("Личные данные").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "person",
                        imageColor: .rosenergo,
                        subTitle: "Агент",
                        title: sessionStore.loginModel!.data.name
                    )
                    SectionItem(
                        imageName: "envelope",
                        imageColor: .rosenergo,
                        subTitle: "Эл.почта",
                        title: sessionStore.loginModel!.data.email
                    )
                }
            }
            #if !os(watchOS)
            Section(header: Text("Уведомления").fontWeight(.bold), footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Выключить уведомления", titleColor: .primary) {
                        openSettings()
                    }
                    Stepper(value: $notificationStore.notifyHour, in: 1...24) {
                        Label(title: {
                            Text("\(notificationStore.notifyHour) ч.")
                        }, icon: {
                            Image(systemName: "timer")
                                .foregroundColor(.rosenergo)
                        })
                    }
                }
                if notificationStore.enabled == .notDetermined {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Включить уведомления", titleColor: .primary) {
                        notificationStore.requestPermission()
                    }
                }
                if notificationStore.enabled == .denied {
                    SectionButton(imageName: "bell", imageColor: .rosenergo, title: "Включить уведомления", titleColor: .primary) {
                        openSettings()
                    }
                }
            }
            Section(header: Text("Виджет").fontWeight(.bold), footer: Text("Если в виджете возникают ошибки, нажмите на кнопку \"Сбросить виджет\".")) {
                SectionButton(imageName: "heart.text.square", imageColor: .rosenergo, title: "Сбросить виджет", titleColor: .primary) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            Section(header: Text("Другое").fontWeight(.bold), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
                SectionButton(imageName: "ant", imageColor: .rosenergo, title: "Сообщить об ошибке", titleColor: .primary) {
                    if MFMailComposeViewController.canSendMail() {
                        showMailView()
                    } else {
                        alertMailType = .error
                        showAlert = true
                    }
                }
            }
            #endif
            Section {
                if !sessionStore.logoutState {
                    SectionButton(imageName: "flame", imageColor: .red, title: "Выйти", titleColor: .red) {
                        showActionSheetExit = true
                    }
                } else {
                    SectionProgress(title: "Подождите")
                }
            }
        }
        .navigationTitle("Настройки")
        .actionSheet(isPresented: $showActionSheetExit) {
            ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [
                .destructive(Text("Выйти")) {
                    sessionStore.logout()
                }, .cancel()
            ])
        }
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
