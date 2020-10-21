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
    
    private func signIn() {
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
            CustomButton("Войти", loading: loading, action: signIn)
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
}
