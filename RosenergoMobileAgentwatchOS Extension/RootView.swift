//
//  RootView.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    var body: some View {
        Group {
            if sessionStore.loginModel != nil {
                MenuView()
            } else {
                SignIn()
            }
        }
    }
}

// MARK: На случай если все таки вернусь к WatchConnectivity!

//struct LoginView: View {
//
//    @State private var error: Bool = true
//
//    var body: some View {
//        VStack {
//            if error {
//                Text("Произошла ошибка")
//                    .fontWeight(.bold)
//                Text("Откройте приложение \"Агент\" на iPhone и нажмите на кнопку \"Повторить\".")
//                    .foregroundColor(.secondary)
//                    .font(.footnote)
//                Spacer()
//                Button(action: {}) {
//                    Text("Повторить")
//                }
//            } else {
//                Text("Выполняется вход")
//                    .fontWeight(.bold)
//                Text("Подождите")
//                    .foregroundColor(.secondary)
//                    .font(.footnote)
//            }
//        }
//    }
//}
