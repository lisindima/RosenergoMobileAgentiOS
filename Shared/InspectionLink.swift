//
//  InspectionLink.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct InspectionLink: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var inspectionID: String
    
    @State private var loadingState: LoadingState<Inspections> = .loading

    private func getInspection() {
        Endpoint.api.fetch(.inspections(inspectionID)) { [self] (result: Result<Inspections, ApiError>) in
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
        LoadingView($loadingState, load: getInspection) { inspection in
            InspectionsDetails(inspection: inspection)
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
