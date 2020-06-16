//
//  ListInspections.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ListInspections: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
    var body: some View {
        List {
            ForEach(sessionStore.inspections.reversed(), id: \.id) { inspection in
                NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                    Text("\(inspection.id)")
                }
            }
        }
        .onAppear(perform: sessionStore.getInspections)
        .navigationBarTitle("Осмотры")
    }
}

struct ListInspections_Previews: PreviewProvider {
    static var previews: some View {
        ListInspections()
    }
}
