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
    @State private var alertItem: AlertItem?
    
    private func login() {
        loading = true
        sessionStore.login(email: email, password: password) { [self] result in
            switch result {
            case .success:
                playHaptic(.success)
                loading = false
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Логин или пароль неверны, либо отсутствует соединение с интернетом.")
                loading = false
                log(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        #if os(iOS)
        iOS
        #elseif os(watchOS)
        watchOS
        #else
        macOS
        #endif
    }
    
    #if os(iOS)
    var iOS: some View {
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
                CustomInput("Эл.почта", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                SecureField("Пароль", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .modifier(InputModifier())
            }
            .padding(.horizontal)
            CustomButton("Войти", loading: loading, action: login)
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
        .customAlert(item: $alertItem)
    }
    #endif
    
    #if os(watchOS)
    var watchOS: some View {
        VStack {
            Text("Мобильный агент")
                .fontWeight(.bold)
                .padding(.vertical)
            TextField("Эл.почта", text: $email)
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .padding(.bottom)
            CustomButton("Войти", loading: loading, action: login)
        }
        .navigationTitle("Мобильный агент")
        .customAlert(item: $alertItem)
    }
    #endif
    
    #if os(macOS)
    var macOS: some View {
        VStack {
            Spacer()
            Text("Мобильный агент")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
            Spacer()
            TextField("Эл.почта", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Пароль", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            CustomButton("Войти", loading: loading, action: login)
                .keyboardShortcut(.defaultAction)
                .padding(.vertical)
            Divider()
                .padding(.bottom, 8)
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
        }
        .padding()
        .frame(width: 500, height: 400)
        .navigationTitle("Мобильный агент")
        .customAlert(item: $alertItem)
    }
    #endif
}
