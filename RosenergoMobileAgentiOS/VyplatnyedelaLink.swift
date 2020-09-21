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
    
    @State private var loadingState: LoadingState<Vyplatnyedela> = .loading

    private func getVyplatnyedela() {
        sessionStore.load(Endpoint.vyplatnyedela(vyplatnyedelaID).url) { [self] (response: Result<Vyplatnyedela, Error>) in
            switch response {
            case let .success(value):
                loadingState = .success(value)
            case let .failure(error):
                loadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            LoadingView(loadingState) { vyplatnyedela in
                VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)
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
