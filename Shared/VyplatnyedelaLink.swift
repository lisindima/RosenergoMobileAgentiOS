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
        sessionStore.fetch(.vyplatnyedela(vyplatnyedelaID)) { [self] (result: Result<Vyplatnyedela, ApiError>) in
            switch result {
            case let .success(value):
                loadingState = .success(value)
            case let .failure(error):
                loadingState = .failure(error)
                log(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        LoadingView($loadingState, load: getVyplatnyedela) { vyplatnyedela in
            VyplatnyedelaDetails(vyplatnyedela: vyplatnyedela)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Закрыть")
                }
            }
        }
    }
}