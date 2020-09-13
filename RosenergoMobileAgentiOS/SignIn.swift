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
    @State private var loading: Bool = false
    @State private var alertItem: AlertItem? = nil
    
    private func signIn(email: String, password: String) {
        loading = true
        sessionStore.login(email: email, password: password) { [self] result in
            switch result {
            case let .success(response):
                sessionStore.loginModel = response
                sessionStore.loginParameters = LoginParameters(email: email, password: password)
                playHaptic(.success)
                loading = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Логин или пароль неверны, либо отсутствует соединение с интернетом.")
                playHaptic(.error)
                loading = false
                log(error)
            }
        }
    }
    
    var body: some View {
        #if os(watchOS)
        watch
        #else
        phone
        #endif
    }
    
    var watch: some View {
        VStack {
            CustomInput(text: $email, name: "Эл.почта")
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .modifier(InputModifier())
            CustomButton(title: "Войти", loading: loading, colorButton: .rosenergo, colorText: .white) {
                signIn(email: email, password: password)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Мобильный агент")
        .customAlert($alertItem)
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
            CustomButton(title: "Войти", loading: loading, colorButton: .rosenergo, colorText: .white) {
                signIn(email: email, password: password)
            }
            .keyboardShortcut(.defaultAction)
            .padding()
            Divider()
            HStack {
                Text("У вас еще нет аккаунта?")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Button(action: {
                    alertItem = AlertItem(title: "Регистрация", message: "Для того, чтобы вы могли зарегистрироваться в приложение, вам необходимо написать на электронную почту lisinde@rosen.ttb.ru.")
                }) {
                    Text("Регистрация")
                        .font(.footnote)
                }
            }
            .padding(.top, 5)
            .padding(.bottom)
        }
        .frame(minWidth: nil, idealWidth: 600, maxWidth: 700, minHeight: nil, idealHeight: nil, maxHeight: nil)
        .customAlert($alertItem)
    }
    #endif
}
