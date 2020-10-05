//
//  ListInspections.swift
//  RosenergoMobileAgentwatchOS Extension
//
//  Created by Дмитрий Лисин on 15.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Espera

struct ListInspections: View {
    
    @ObservedObject var sessionStore: SessionStore = SessionStore.shared
    
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
                LoadingFlowerView()
                    .frame(width: 24, height: 24)
            } else {
                List {
                    ForEach(sessionStore.inspections.reversed(), id: \.id) { inspection in
                        NavigationLink(destination: InspectionsDetails(inspection: inspection)) {
                            InspectionsItems(inspection: inspection)
                        }
                    }
                }
                .contextMenu(menuItems: {
                    Button(action: {
                        sessionStore.getInspections()
                    }, label: {
                        VStack{
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                            Text("Обновить список")
                        }
                    })
                })
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
