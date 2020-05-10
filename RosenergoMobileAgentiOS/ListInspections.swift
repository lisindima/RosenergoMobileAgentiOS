//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListInspections: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    var body: some View {
        VStack {
            if sessionStore.inspections.isEmpty {
                ActivityIndicator(styleSpinner: .large)
                    .onAppear {
                        self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel.data.apiToken)
                }
            } else {
                List {
                    ForEach(self.sessionStore.inspections, id: \.id) { inspection in
                        ListInspectionsItems(inspection: inspection)
                    }
                }
            }
        }.navigationBarTitle("Осмотры", displayMode: .inline)
    }
}

struct ListInspectionsItems: View {
    
    var inspection: Inspections
    
    var body: some View {
        HStack {
            VStack {
                Text(inspection.insuranceContractNumber)
                Text(inspection.carBodyNumber)
                Text(inspection.carModel)
                Text(inspection.carVin)
                Text(inspection.carVin)
            }
            Spacer()
            WebImage(url: URL(string: inspection.photos.first!.path))
                .resizable()
                .indicator(.activity)
                .frame(width: 100, height: 100)
        }
    }
}
