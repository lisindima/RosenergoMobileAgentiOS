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
    
    @State private var openListInspections: Bool = false
    @State private var openCreateInspections: Bool = false
    @State private var showActionSheetExit: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        self.openListInspections = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .opacity(0.2)
                                .frame(maxWidth: .infinity, maxHeight: 100)
                            VStack {
                                Image(systemName: "car")
                                    .font(.largeTitle)
                                    .foregroundColor(.purple)
                                    .padding(.bottom, 4)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Сделать осмотр")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.purple)
                            }
                        }
                    }
                    .padding(.trailing, 4)
                    .sheet(isPresented: $openCreateInspections) {
                        CreateInspections()
                            .environmentObject(self.sessionStore)
                    }
                    Button(action: {
                        self.openListInspections = true
                    }) {
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
                    }
                    .padding(.leading, 4)
                    .sheet(isPresented: $openListInspections) {
                        ListInspections()
                            .environmentObject(self.sessionStore)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
            }
            .navigationBarTitle("Мобильный агент")
            .navigationBarItems(trailing: Button(action: {
                self.showActionSheetExit = true
            }) {
                Image(systemName: "flame")
                    .imageScale(.large)
            })
            .actionSheet(isPresented: $showActionSheetExit) {
                ActionSheet(title: Text("Вы уверены, что хотите выйти из этого аккаунта?"), message: Text("Для продолжения использования приложения вам потребуется повторно войти в аккаунт!"), buttons: [.destructive(Text("Выйти")) {
                    print("выйти")
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
