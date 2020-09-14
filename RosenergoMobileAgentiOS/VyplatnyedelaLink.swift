//
//  VyplatnyedelaLink.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct VyplatnyedelaLink: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var vyplatnyedelaID: String
    
    @State private var vyplatnyedela: Vyplatnyedela? = nil
    @State private var loadingState: LoadingState = .loading

    private func getVyplatnyedela() {
        sessionStore.load("vyplatnyedelas/" + "\(vyplatnyedelaID)") { [self] (response: Result<Vyplatnyedela, Error>) in
            switch response {
            case let .success(value):
                vyplatnyedela = value
                loadingState = .success
            case let .failure(error):
                loadingState = .failure(error)
                log(error)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            LoadingView(loadingState) {
                VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela!)
            }
            .onAppear(perform: getVyplatnyedela)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Закрыть")
                    }
                }
            }
        }
    }
}
