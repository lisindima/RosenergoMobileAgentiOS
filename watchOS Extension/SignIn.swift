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
    @State private var loading: Bool = false
    @State private var alertItem: AlertItem? = nil
    
    private func signIn(email: String, password: String) {
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
            Text("Мобильный агент")
                .fontWeight(.bold)
                .padding(.vertical)
            TextField("Эл.почта", text: $email)
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .padding(.bottom)
            CustomButton("Войти", loading: loading) {
                signIn(email: email, password: password)
            }
        }
        .navigationTitle("Мобильный агент")
        .customAlert(item: $alertItem)
    }
}
