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
    @State private var test: Int = 131
    @State private var testLimit: Int = 500
    
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
                Section(header: Text("Личные данные")) {
                    Text(sessionStore.loginModel?.data.name ?? "Ошибка")
                    Text(sessionStore.loginModel?.data.email ?? "Ошибка")
                    Text(sessionStore.loginModel?.data.apiToken ?? "Ошибка")
                }
                Section(header: Text("Кэш изображений"), footer: Text("Если приложение занимает слишком много места, очистка кэша изображений поможет решить эту проблему.")) {
                    ZStack {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 60)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                                    .foregroundColor(Color.rosenergo.opacity(0.2))
                                Rectangle()
                                    .frame(width: (CGFloat(self.test) / CGFloat(self.testLimit)) * geometry.size.width, height: 60)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                                    .foregroundColor(.rosenergo)
                                    .animation(.linear)
                                HStack {
                                    Spacer()
                                    Text("\(self.test) MB / \(self.testLimit) MB")
                                        .foregroundColor(.white)
                                        .font(.custom("Futura", size: 24))
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(height: 60)
                    .padding(.vertical)
                    HStack {
                        Image(systemName: "trash")
                            .frame(width: 24)
                            .foregroundColor(.rosenergo)
                        Button("Очистить кэш изображений") {
                            print("")
                        }.foregroundColor(.primary)
                    }
                }
                Section(header: Text("Другое"), footer: Text("Если в приложение возникают ошибки, нажмите на кнопку \"Сообщить об ошибке\".")) {
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
                        self.sessionStore.logout()
                        self.presentationMode.wrappedValue.dismiss()
                        }, .cancel()
                    ])
                }
            }
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Настройки")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Закрыть")
                    .bold()
            })
        }
        .accentColor(.rosenergo)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
