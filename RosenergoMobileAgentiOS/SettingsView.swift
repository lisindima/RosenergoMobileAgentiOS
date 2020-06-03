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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Личные данные".uppercased())) {
                    Text(sessionStore.loginModel?.data.name ?? "Ошибка")
                    Text(sessionStore.loginModel?.data.email ?? "Ошибка")
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
            .navigationBarTitle("Настройки", displayMode: .inline)
        }
        .accentColor(.rosenergo)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
