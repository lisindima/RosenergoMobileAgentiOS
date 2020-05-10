//
//  SignIn.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Эл.почта", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.sessionStore.login(email: self.email, password: self.password)
                }) {
                    Text("Войти")
                }
            }
            .padding()
            .navigationBarTitle("Вход")
        }
    }
}
