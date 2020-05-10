//
//  ListInspections.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

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
                        Text(inspection.carRegNumber)
                    }
                }
            }
        }
    }
}
