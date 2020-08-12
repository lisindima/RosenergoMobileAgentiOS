//
//  License.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 12.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire

struct License: View {
    
    @EnvironmentObject private var sessionStore: SessionStore
    
    var body: some View {
        VStack {
            if sessionStore.licenseModel.isEmpty, !sessionStore.licenseLoadingFailure {
                ProgressView()
                    .onAppear(perform: sessionStore.loadLicense)
            } else if sessionStore.licenseModel.isEmpty, sessionStore.licenseLoadingFailure {
                Text("Нет подключения к интернету!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .onAppear(perform: sessionStore.loadLicense)
            } else {
                Form {
                    ForEach(sessionStore.licenseModel.sorted { $0.nameFramework < $1.nameFramework }, id: \.id) { license in
                        NavigationLink(destination: LicenseDetail(license: license)) {
                            Text(license.nameFramework)
                        }
                    }
                }
            }
        }
        .navigationTitle("Лицензии")
    }
}

struct LicenseDetail: View {
    
    var license: LicenseModel
    
    var body: some View {
        VStack {
            ScrollView {
                Text(license.textLicenseFramework)
                    .font(.system(size: 14, design: .monospaced))
                    .padding()
            }
        }
        .navigationTitle(license.nameFramework)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Link(destination: URL(string: license.urlFramework)!) {
                    Image(systemName: "safari")
                        .imageScale(.large)
                }
            }
        }
    }
}
