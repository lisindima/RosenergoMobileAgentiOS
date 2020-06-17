//
//  SettingsView.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 16.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showActionSheetExit: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Личные данные".uppercased())) {
                HStack {
                    Image(systemName: "person")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Агент")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.name ?? "Ошибка")
                            .font(.footnote)
                    }
                }
                HStack {
                    Image(systemName: "envelope")
                        .frame(width: 24)
                        .foregroundColor(.rosenergo)
                    VStack(alignment: .leading) {
                        Text("Эл.почта")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(sessionStore.loginModel?.data.email ?? "Ошибка")
                            .font(.footnote)
                    }
                }
            }
            Section {
                Button(action:  {
                    self.showActionSheetExit = true
                }) {
                    HStack {
                        Image(systemName: "flame")
                            .frame(width: 24)
                        Text("Выйти")
                    }.foregroundColor(.red)
                }
            }.actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    self.presentationMode.wrappedValue.dismiss()
                    self.sessionStore.logout()
                    }, .cancel()
                ])
            }
        }.navigationBarTitle("Настройки")
    }
}
