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
    @State private var showActionSheetExit: Bool = false
    @State private var showFeedback: Bool = false
    @State private var loading: Bool = false
    
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
            #if !targetEnvironment(macCatalyst) || os(watchOS)
            Section(footer: Text("Здесь вы можете управлять уведомлениями приложения.")) {
                SectionNavigationLink(
                    imageName: "bell",
                    title: "Уведомления",
                    destination: NotificationView()
                )
            }
            #endif
            Section(header: Text("Другое").fontWeight(.bold)) {
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
        .userFeedback(isPresented: $showFeedback)
//        .actionSheet(isPresented: $showActionSheetExit) {
//            ActionSheet(
//                title: Text("Вы уверены, что хотите выйти из этого аккаунта?"),
//                message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"),
//                buttons: [
//                    .destructive(Text("Выйти"), action: logout),
//                    .cancel(),
//                ]
//            )
//        }
    }
}
