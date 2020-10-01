//
//  SettingsView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if os(iOS)
import MessageUI
#endif

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @State private var alertItem: AlertItem? = nil
    @State private var showActionSheetExit: Bool = false
    @State private var showMailFeedback: Bool = false
    @State private var loading: Bool = false
    
    #if os(iOS)
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)!
    #endif
    
    #if os(iOS)
    private func feedback() {
        if MFMailComposeViewController.canSendMail() {
            showMailFeedback = true
        } else {
            alertItem = AlertItem(title: "Не установлено приложение \"Почта\"", message: "Для отправки сообщений об ошибках вам понадобится официальное приложение \"Почта\", установите его из App Store.")
        }
    }
    #endif
    
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
    
    var footerFeedback: some View {
        #if os(watchOS)
        return EmptyView()
        #else
        return Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")
        #endif
    }
    
    var body: some View {
        #if os(watchOS)
        settings
        #else
        settings
            .sheet(isPresented: $showMailFeedback) {
                MailFeedback(alertItem: $alertItem)
                    .ignoresSafeArea(edges: .bottom)
                    .accentColor(.rosenergo)
            }
        #endif
    }
    
    var settings: some View {
        Form {
            if let agent = sessionStore.loginModel {
                Section(header: Text("Личные данные").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "person",
                        subTitle: "Агент",
                        title: agent.name
                    )
                    SectionItem(
                        imageName: "envelope",
                        subTitle: "Эл.почта",
                        title: agent.email
                    )
                }
            }
            #if os(iOS)
            Section(header: Text("Уведомления").fontWeight(.bold), footer: footerNotification) {
                if notificationStore.enabled == .authorized {
                    SectionLink(
                        imageName: "bell",
                        title: "Выключить уведомления",
                        destination: settingsURL
                    )
                    Stepper(value: $notificationStore.notifyHour, in: 1 ... 24) {
                        Image(systemName: "timer")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Text("\(notificationStore.notifyHour) ч.")
                    }
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
                        destination: settingsURL
                    )
                }
            }
            #endif
            Section(header: Text("Другое").fontWeight(.bold), footer: footerFeedback) {
                SectionNavigationLink(
                    imageName: "doc.plaintext",
                    title: "Лицензии",
                    destination: License()
                )
                #if os(iOS)
                SectionLink(
                    imageName: "star",
                    title: "Оценить",
                    showLinkLabel: true,
                    destination: URL(string: "https://itunes.apple.com/app/id1513090178?action=write-review")!
                )
                SectionButton(
                    imageName: "ant",
                    title: "Сообщить об ошибке",
                    action: feedback
                )
                #endif
            }
            Section(footer: Text("Версия: \(getVersion())")) {
                if !loading {
                    SectionButton(
                        imageName: "flame",
                        imageColor: .red,
                        title: "Выйти",
                        titleColor: .red
                    ) {
                        showActionSheetExit = true
                    }
                } else {
                    #if os(watchOS)
                    Label {
                        Text("Подождите")
                    } icon: {
                        ProgressView()
                    }
                    #else
                    HStack {
                        ProgressView()
                        Text("Подождите")
                            .padding(.leading, 12)
                    }
                    #endif
                }
            }
        }
        .navigationTitle("Настройки")
        .customAlert(item: $alertItem)
        .actionSheet(isPresented: $showActionSheetExit) {
            ActionSheet(
                title: Text("Вы уверены, что хотите выйти из этого аккаунта?"),
                message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"),
                buttons: [
                    .destructive(Text("Выйти")) {
                        loading = true
                        sessionStore.logout {
                            loading = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    },
                    .cancel(),
                ]
            )
        }
    }
}
