//
//  Changelog.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 12.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct Changelog: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var body: some View {
        LoadingView(sessionStore.changelogLoadingState) { changelogModel in
            Form {
                ForEach(changelogModel.sorted { $0.version > $1.version }, id: \.id) { changelog in
                    Section(header:
                        HStack(alignment: .bottom) {
                            Text(changelog.version)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(appVersion == changelog.version ? "Текущая версия" : changelog.dateBuild)
                                .fontWeight(.bold)
                        }
                    ) {
                        VStack(alignment: .leading) {
                            if !changelog.whatsNew.isEmpty {
                                Text("Новое")
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                    .padding(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(Color.purple.opacity(0.2))
                                    )
                                Text(changelog.whatsNew)
                                    .font(.subheadline)
                            }
                            if !changelog.whatsNew.isEmpty, !changelog.bugFixes.isEmpty {
                                Divider()
                            }
                            if !changelog.bugFixes.isEmpty {
                                Text("Исправления")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(Color.green.opacity(0.2))
                                    )
                                Text(changelog.bugFixes)
                                    .font(.subheadline)
                            }
                        }.padding(.vertical, 3)
                    }
                }
            }
        }
        .onAppear(perform: sessionStore.getChangelog)
        .navigationTitle("Что нового?")
    }
}
