//
//  Changelog.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 12.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

struct Changelog: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var body: some View {
        VStack {
            if sessionStore.сhangelogModel.isEmpty, !sessionStore.changelogLoadingFailure {
                ProgressView()
                    .onAppear(perform: sessionStore.loadChangelog)
            } else if sessionStore.сhangelogModel.isEmpty, sessionStore.changelogLoadingFailure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .onAppear(perform: sessionStore.loadChangelog)
            } else {
                Form {
                    ForEach(sessionStore.сhangelogModel.sorted { $0.version > $1.version }, id: \.id) { changelog in
                        Section(header:
                            HStack(alignment: .bottom) {
                                Text(changelog.version)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(appVersion == changelog.version ? "Текущая версия" : changelog.dateBuild)
                            }
                        ) {
                            VStack(alignment: .leading) {
                                if !changelog.whatsNew.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Новое:")
                                            .bold()
                                            .foregroundColor(.purple)
                                            .padding(5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundColor(Color.purple.opacity(0.2))
                                        )
                                            .padding(.bottom, 3)
                                        Text(changelog.whatsNew)
                                            .font(.system(size: 16))
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 3)
                                }
                                if !changelog.whatsNew.isEmpty, !changelog.bugFixes.isEmpty {
                                    Divider()
                                }
                                if !changelog.bugFixes.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Исправления:")
                                            .bold()
                                            .foregroundColor(.green)
                                            .padding(5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundColor(Color.green.opacity(0.2))
                                        )
                                            .padding(.bottom, 3)
                                        Text(changelog.bugFixes)
                                            .font(.system(size: 16))
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 3)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Что нового?")
    }
}
