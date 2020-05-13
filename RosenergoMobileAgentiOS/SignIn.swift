//
//  SignIn.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import KeyboardObserving

struct SignIn: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Мобильный агент")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                CustomInput(text: $email, name: "Эл.почта")
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                SecureField("Пароль", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .modifier(InputModifier())
                    .padding(.horizontal)
                CustomButton(label: sessionStore.loadingLogin ? "Загрузка" : "Войти", loading: sessionStore.loadingLogin, colorButton: .purple) {
                    self.sessionStore.login(email: self.email, password: self.password)
                }.padding()
            }.keyboardObserving()
        }
    }
}
