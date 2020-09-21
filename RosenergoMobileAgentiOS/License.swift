//
//  License.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 12.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct License: View {
    @EnvironmentObject private var sessionStore: SessionStore

    var body: some View {
        LoadingView(sessionStore.licenseLoadingState) { licenseModel in
            Form {
                Section(footer: Text("Здесь перечислены проекты с открытым исходным кодом, которые используются в этом приложении.")) {
                    ForEach(licenseModel.sorted { $0.nameFramework < $1.nameFramework }, id: \.id) { license in
                        NavigationLink(destination: LicenseDetail(license: license)) {
                            Text(license.nameFramework)
                        }
                    }
                }
            }
        }
        .onAppear(perform: sessionStore.getLicense)
        .navigationTitle("Лицензии")
    }
}

struct LicenseDetail: View {
    var license: LicenseModel
    
    var body: some View {
        ScrollView {
            Text(license.textLicenseFramework)
                .font(.system(size: 14, design: .monospaced))
                .padding()
        }
        .navigationTitle(license.nameFramework)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Link(destination: license.urlFramework) {
                    Image(systemName: "safari")
                        .imageScale(.large)
                }
            }
        }
    }
}
