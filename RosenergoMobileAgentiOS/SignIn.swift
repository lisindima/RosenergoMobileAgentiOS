//
//  SignIn.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject private var sessionStore: SessionStore

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationView {
            #if os(watchOS)
                watch
            #else
                phone
            #endif
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func alert(title: String, message: String) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .cancel()
        )
    }

    var watch: some View {
        VStack {
            CustomInput(text: $email, name: "Эл.почта")
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .modifier(InputModifier())
            CustomButton(title: "Войти", loading: sessionStore.loginState, colorButton: .rosenergo, colorText: .white) {
                sessionStore.login(email: email, password: password)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Мобильный агент")
        .alert(item: $sessionStore.alertItem) { error in
            alert(title: error.title, message: error.message)
        }
    }

    #if !os(watchOS)
        var phone: some View {
            VStack {
                Spacer()
                Image("rosenergo")
                    .resizable()
                    .frame(width: 300, height: 169)
                Text("Мобильный агент")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Group {
                    CustomInput(text: $email, name: "Эл.почта")
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Пароль", text: $password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .modifier(InputModifier())
                }
                .padding(.horizontal)
                CustomButton(title: "Войти", loading: sessionStore.loginState, colorButton: .rosenergo, colorText: .white) {
                    sessionStore.login(email: email, password: password)
                }
                .keyboardShortcut(.defaultAction)
                .padding()
                Divider()
                HStack {
                    Text("У вас еще нет аккаунта?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Button(action: {
                        sessionStore.alertItem = AlertItem(title: "Регистрация", message: "Для того, чтобы вы могли зарегистрироваться в приложение, вам необходимо написать на электронную почту lisinde@rosen.ttb.ru.", action: false)
                    }) {
                        Text("Регистрация")
                            .font(.footnote)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .frame(minWidth: nil, idealWidth: 600, maxWidth: 700, minHeight: nil, idealHeight: nil, maxHeight: nil)
            .alert(item: $sessionStore.alertItem) { error in
                alert(title: error.title, message: error.message)
            }
        }
    #endif
}
