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
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var alertItem: AlertItem?
    @State private var showFeedback: Bool = false
    @State private var loading: Bool = false
    @State private var showActionSheetExit: Bool = false
    
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
    
    var body: some View {
        #if os(macOS)
        formSettings
        #else
        formSettings
            .navigationTitle("Настройки")
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
        #endif
    }
    
    var formSettings: some View {
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
            Section(footer: Text("Здесь вы можете управлять уведомлениями приложения.")) {
                SectionNavigationLink(
                    imageName: "bell",
                    title: "Уведомления",
                    destination: NotificationView()
                )
            }
            #endif
            Section(header: Text("Другое").fontWeight(.bold)) {
                #if !os(macOS)
                SectionNavigationLink(
                    imageName: "doc.plaintext",
                    title: "Лицензии",
                    destination: License()
                )
                #endif
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
                #if !os(macOS)
                SectionButton(
                    imageName: "ant",
                    title: "Обратная связь"
                ) {
                    showFeedback = true
                }
                #endif
            }
            Section(footer: Text("Версия: \(getVersion)")) {
                if !loading {
                    SectionButton(
                        imageName: "flame",
                        imageColor: .red,
                        title: "Выйти",
                        titleColor: .red
                    ) {
                        #if os(macOS)
                        logout()
                        #else
                        showActionSheetExit = true
                        #endif
                    }
                } else {
                    #if os(iOS)
                    HStack {
                        ProgressView()
                        Text("Подождите")
                            .padding(.leading, 12)
                    }
                    #else
                    Label {
                        Text("Подождите")
                    } icon: {
                        ProgressView()
                    }
                    #endif
                }
            }
        }
        .customAlert(item: $alertItem)
    }
}
