//
//  SignIn.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SignIn: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            TextField("Эл.почта", text: $email)
                .textContentType(.emailAddress)
            SecureField("Пароль", text: $password)
                .textContentType(.password)
            Button(action: {
                self.sessionStore.login(email: self.email, password: self.password)
            }) {
                Text("Вход")
            }
        }.navigationBarTitle("Агент")
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
