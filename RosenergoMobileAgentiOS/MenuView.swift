//
//  MenuView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var showActionSheetExit: Bool = false
    @State private var showSettings: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: CreateInspections()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.rosenergo)
                                .opacity(0.2)
                                .frame(maxWidth: .infinity, maxHeight: 100)
                            VStack {
                                Image(systemName: "car")
                                    .font(.largeTitle)
                                    .foregroundColor(.rosenergo)
                                    .padding(.bottom, 4)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Провести осмотр")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.rosenergo)
                            }
                        }
                    }.padding(.trailing, 4)
                    NavigationLink(destination: ListInspections()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red)
                                .opacity(0.2)
                                .frame(maxWidth: .infinity, maxHeight: 100)
                            VStack {
                                Image(systemName: "list.bullet.below.rectangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                    .padding(.bottom, 4)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Осмотры")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.red)
                            }
                        }
                    }.padding(.leading, 4)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
            }
            .navigationBarTitle("Мобильный агент")
            .navigationBarItems(leading: Button(action: {
                self.showActionSheetExit = true
            }) {
                Image(systemName: "flame")
                    .imageScale(.large)
                }, trailing: Button(action: {
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .sheet(isPresented: $showSettings) {
                            SettingsView()
                                .environmentObject(self.sessionStore)
                        }
            })
            .actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    self.sessionStore.logout(apiToken: self.sessionStore.loginModel!.data.apiToken)
                    }, .cancel()
                ])
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
