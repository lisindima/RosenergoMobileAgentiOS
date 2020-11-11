//
//  VyplatnyedelaLink.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 14.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct VyplatnyedelaLink: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var loadingState: LoadingState<Vyplatnyedela> = .loading
    
    var vyplatnyedelaID: String

    private func getVyplatnyedela() {
        Endpoint.api.fetch(.vyplatnyedela(vyplatnyedelaID)) { [self] (result: Result<Vyplatnyedela, ApiError>) in
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
