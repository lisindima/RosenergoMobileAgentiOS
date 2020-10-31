//
//  SettingsView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import URLImage
import UserFeedback

struct SettingsView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var notificationStore: NotificationStore
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var alertItem: AlertItem? = nil
    @State private var showActionSheetExit: Bool = false
    @State private var showFeedback: Bool = false
    @State private var loading: Bool = false
    
    #if os(iOS)
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)
    #endif
    private let appstoreURL = URL(string: "https://itunes.apple.com/app/id1513090178?action=write-review")
    
    private func removeCache() {
        URLImageService.shared.removeAllCachedImages()
        alertItem = AlertItem(title: "Успешно", message: "Кэш изображений успешно очищен.")
    }
    
    private func logout() {
        loading = true
        sessionStore.logout {
            loading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    @ViewBuilder var footerNotification: some View {
        switch notificationStore.enabled {
        case .denied:
            Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\", после чего активируйте уведомления в настройках.")
        case .notDetermined:
            Text("Чтобы активировать уведомления нажмите на кнопку \"Включить уведомления\".")
        case .authorized:
            Text("Укажите, через какое время вам придет уведомление после сохранённого осмотра.")
        default:
            Text("")
        }
    }
    
    var body: some View {
        Form {
            if let agent = sessionStore.loginModel {
                Section(header: Text("Личные данные").fontWeight(.bold).padding(.horizontal)) {
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
            Section(header: Text("Уведомления").fontWeight(.bold).padding(.horizontal), footer: footerNotification.padding(.horizontal)) {
                if notificationStore.enabled == .authorized {
                    SectionLink(
                        imageName: "bell",
                        title: "Выключить уведомления",
                        url: settingsURL
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
                        url: settingsURL
                    )
                }
            }
            #endif
            Section(header: Text("Другое").fontWeight(.bold).padding(.horizontal), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Обратная связь\".").padding(.horizontal)) {
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
                    url: appstoreURL
                )
                #endif
                SectionButton(
                    imageName: "trash",
                    title: "Очистить кэш изображений",
                    action: removeCache
                )
                SectionButton(
                    imageName: "ant",
                    title: "Обратная связь"
                ) {
                    showFeedback = true
                }
            }
            Section(footer: Text("Версия: \(getVersion())").padding(.horizontal)) {
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
        .userFeedback(isPresented: $showFeedback)
        .actionSheet(isPresented: $showActionSheetExit) {
            ActionSheet(
                title: Text("Вы уверены, что хотите выйти из этого аккаунта?"),
                message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"),
                buttons: [
                    .destructive(Text("Выйти"), action: logout),
                    .cancel(),
                ]
            )
        }
    }
}
