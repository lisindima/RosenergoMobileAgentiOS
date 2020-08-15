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
#endif

struct SettingsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var sessionStore: SessionStore
    
    #if !os(watchOS)
    @EnvironmentObject private var notificationStore: NotificationStore
    private let settingsURL = URL(string: UIApplication.openSettingsURLString)
    #endif
    
    @State private var showAlert: Bool = false
    @State private var alertMailType: AlertMailType = .sent
    @State private var showActionSheetExit: Bool = false
    
    #if !os(watchOS)
    private func showMailView() {
        DispatchQueue.main.async {
            let mailFeedback = UIHostingController(rootView:
                MailFeedback(showAlert: $showAlert, alertMailType: $alertMailType)
                    .ignoresSafeArea(edges: .bottom)
                    .accentColor(.rosenergo)
            )
            UIApplication.shared.windows.first?.rootViewController?.present(
                mailFeedback, animated: true, completion: nil
            )
        }
    }
    #endif
    
    private var appVersionView: some View {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return Text("Версия: \(version) (\(build))")
        } else {
            return Text("")
        }
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
    
    var body: some View {
        Form {
            if sessionStore.loginModel != nil {
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
                    SectionLink(
                        imageName: "bell",
                        imageColor: .rosenergo,
                        title: "Выключить уведомления",
                        titleColor: .primary,
                        destination: settingsURL!
                    )
                    Stepper(value: $notificationStore.notifyHour, in: 1...24) {
                        Image(systemName: "timer")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Text("\(notificationStore.notifyHour) ч.")
                    }
                }
                if notificationStore.enabled == .notDetermined {
                    SectionButton(
                        imageName: "bell",
                        imageColor: .rosenergo,
                        title: "Включить уведомления",
                        titleColor: .primary
                    ) {
                        notificationStore.requestPermission()
                    }
                }
                if notificationStore.enabled == .denied {
                    SectionLink(
                        imageName: "bell",
                        imageColor: .rosenergo,
                        title: "Включить уведомления",
                        titleColor: .primary,
                        destination: settingsURL!
                    )
                }
            }
            #endif
            Section(header: Text("Другое").fontWeight(.bold), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
                NavigationLink(destination: Changelog()) {
                    Image(systemName: "wand.and.stars.inverse")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    Text("Что нового?")
                }
                NavigationLink(destination: License()) {
                    Image(systemName: "doc.plaintext")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    Text("Лицензии")
                }
                #if !os(watchOS)
                SectionLink(
                    imageName: "star",
                    imageColor: .rosenergo,
                    title: "Оценить",
                    titleColor: .primary,
                    showLinkLabel: true,
                    destination: URL(string: "https://itunes.apple.com/app/id1513090178?action=write-review")!
                )
                SectionButton(
                    imageName: "ant",
                    imageColor: .rosenergo,
                    title: "Сообщить об ошибке",
                    titleColor: .primary
                ) {
                    if MFMailComposeViewController.canSendMail() {
                        showMailView()
                    } else {
                        alertMailType = .error
                        showAlert = true
                    }
                }
                #endif
            }
            Section(footer: appVersionView) {
                if !sessionStore.logoutState {
                    SectionButton(
                        imageName: "flame",
                        imageColor: .red,
                        title: "Выйти",
                        titleColor: .red
                    ) {
                        showActionSheetExit = true
                    }
                } else {
                    HStack {
                        ProgressView()
                        Text("Подождите")
                            .padding(.leading, 12)
                    }
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
