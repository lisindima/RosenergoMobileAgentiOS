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
                    UIApplication.shared.hideKeyboard()
                    self.sessionStore.login(email: self.email, password: self.password)
                }.padding()
            }
            .keyboardObserving()
            .frame(minWidth: nil, idealWidth: 600, maxWidth: 700, minHeight: nil, idealHeight: nil, maxHeight: nil)
            .alert(isPresented: $sessionStore.showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Логин или пароль неверны, либо отсутствует соединение с интернетом."), dismissButton: .default(Text("Закрыть")))
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
