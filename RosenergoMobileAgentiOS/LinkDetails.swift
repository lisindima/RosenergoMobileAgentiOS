//
//  LinkDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct LinkDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var inspectionID: String
    
    @State private var inspection: Inspections? = nil
    @State private var loadingState: LoadingState = .loading

    func getInspection() {
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
            VStack {
                switch loadingState {
                case .success:
                    InspectionsDetails(inspection: inspection!)
                case .loading:
                    ProgressView("Загрузка")
                        .onAppear(perform: getInspection)
                case .failure:
                    Text("Нет подключения к интернету!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
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
}
