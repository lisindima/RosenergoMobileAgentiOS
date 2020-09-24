//
//  InspectionLink.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct InspectionLink: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var inspectionID: String
    
    @State private var loadingState: LoadingState<Inspections> = .loading

    private func getInspection() {
        sessionStore.fetch(.inspections(inspectionID)) { [self] (result: Result<Inspections, UploadError>) in
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
        NavigationView {
            LoadingView(loadingState) { inspection in
                InspectionsDetails(inspection: inspection)
            }
            .onAppear(perform: getInspection)
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
