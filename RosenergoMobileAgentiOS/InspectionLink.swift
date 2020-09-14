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
    
    @State private var inspection: Inspections? = nil
    @State private var loadingState: LoadingState = .loading

    private func getInspection() {
        sessionStore.load("inspection/" + "\(inspectionID)") { [self] (response: Result<Inspections, Error>) in
            switch response {
            case let .success(value):
                inspection = value
                loadingState = .success
            case let .failure(error):
                loadingState = .failure
                log(error)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            LoadingView(loadingState) {
                InspectionsDetails(inspection: inspection!)
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
