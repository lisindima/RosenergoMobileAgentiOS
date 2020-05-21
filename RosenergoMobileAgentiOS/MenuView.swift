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
    
    @State private var showSettings: Bool = false
    
    private var appVersionView: some View {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return Text("Версия: \(version) (\(build))")
        } else {
            return Text("#chad")
        }
    }
    
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
                                    .foregroundColor(.rosenergo)
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
                                    .foregroundColor(.red)
                            }
                        }
                    }.padding(.leading, 4)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                HStack {
                    NavigationLink(destination: CreateInspections()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple)
                                .opacity(0.2)
                                .frame(maxWidth: .infinity, maxHeight: 100)
                            VStack {
                                Image(systemName: "tray.2")
                                    .font(.largeTitle)
                                    .foregroundColor(.purple)
                                    .padding(.bottom, 4)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Выплатные дела")
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
                appVersionView
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(self.sessionStore)
            }
            .navigationBarTitle("Мобильный агент")
            .navigationBarItems(trailing: Button(action: {
                    self.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .imageScale(.large)
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
