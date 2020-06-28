//
//  ListInspections.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct ListInspections: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    @State private var text: String = ""
    
    var body: some View {
        Group {
            if sessionStore.inspections.isEmpty && sessionStore.inspectionsLoadingState == .failure {
                Text("Нет подключения к интернету!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && sessionStore.inspectionsLoadingState == .success {
                Text("Нет осмотров")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Добавьте свой первый осмотр и он отобразиться здесь.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else if sessionStore.inspections.isEmpty && sessionStore.inspectionsLoadingState == .loading {
                ProgressView()
            } else {
                List {
                    Section {
                        TextField("Поиск", text: $text)
                    }
                    Section {
                        ForEach(sessionStore.inspections.reversed(), id: \.id) { inspection in
                            NavigationLink(destination: InspectionsDetails(inspection: inspection).environmentObject(sessionStore)) {
                                InspectionsItems(inspection: inspection)
                            }
                        }
                    }
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
