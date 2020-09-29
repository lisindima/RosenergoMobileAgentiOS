//
//  SignIn.swift
//  RosenergoMobileAgent (watchOS Extension)
//
//  Created by Дмитрий Лисин on 29.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertItem: AlertItem? = nil
    
    private func signIn(email: String, password: String) {
        sessionStore.login(email: email, password: password) { [self] result in
            switch result {
            case .success:
                playHaptic(.success)
            case let .failure(error):
                alertItem = AlertItem(title: "Ошибка", message: "Логин или пароль неверны, либо отсутствует соединение с интернетом.")
                log(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Мобильный агент")
                .fontWeight(.bold)
                .padding(.vertical)
            TextField("Эл.почта", text: $email)
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .padding(.bottom)
            Button("Войти") {
                signIn(email: email, password: password)
            }
        }
        .navigationTitle("Мобильный агент")
        .customAlert(item: $alertItem)
    }
}
