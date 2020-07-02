//
//  SignIn.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if !os(watchOS)
import KeyboardObserving
#endif

struct SignIn: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var email: String = ""
    @State private var password: String = ""
    
   @ViewBuilder var body: some View {
        #if os(watchOS)
        watch
            .alert(isPresented: $sessionStore.showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Логин или пароль неверны, либо отсутствует соединение с интернетом."), dismissButton: .default(Text("Закрыть")))
            }
        #else
        phone
            .keyboardObserving()
            .frame(minWidth: nil, idealWidth: 600, maxWidth: 700, minHeight: nil, idealHeight: nil, maxHeight: nil)
            .alert(isPresented: $sessionStore.showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Логин или пароль неверны, либо отсутствует соединение с интернетом."), dismissButton: .default(Text("Закрыть")))
            }
        #endif
    }
    
    var watch: some View {
        NavigationView {
            VStack {
                TextField("Эл.почта", text: $email)
                    .textContentType(.emailAddress)
                SecureField("Пароль", text: $password)
                    .textContentType(.password)
                Button(action: {
                    self.sessionStore.login(email: self.email, password: self.password)
                }) {
                    Text("Войти")
                }
            }.navigationBarTitle("Агент")
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
            CustomButton(label: sessionStore.loadingLogin ? "Загрузка" : "Войти", loading: sessionStore.loadingLogin, colorButton: .rosenergo, colorText: .white) {
                self.sessionStore.login(email: self.email, password: self.password)
            }.padding()
        }
    }
    #endif
}
