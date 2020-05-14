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
    
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionStore.inspections.isEmpty {
                    ActivityIndicator(styleSpinner: .large)
                        .onAppear {
                            self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
                    }
                } else {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 6)
                    List {
                        ForEach(self.sessionStore.inspections.filter {
                            self.searchText.isEmpty ? true : $0.insuranceContractNumber.localizedStandardContains(self.searchText)
                        }, id: \.id) { inspection in
                            NavigationLink(destination: ListInspectionsDetails(inspection: inspection)) {
                                ListInspectionsItems(inspection: inspection)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Осмотры")
            .navigationBarItems(leading: Button(action: {
                self.sessionStore.getInspections(apiToken: self.sessionStore.loginModel!.data.apiToken)
            }) {
                Image(systemName: "arrow.2.circlepath.circle")
                    .imageScale(.large)
                }, trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Закрыть")
                        .bold()
            })
        }.accentColor(.rosenergo)
    }
}

struct ListInspectionsItems: View {
    
    var inspection: Inspections
    let noImageUrl = "https://firebasestorage.googleapis.com/v0/b/altgtu-46659.appspot.com/o/placeholder%2Fplaceholder.jpeg?alt=media&token=8f554741-2bfb-41ef-82b0-fbc64f0ffdf6"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(inspection.insuranceContractNumber)
                Text(inspection.carBodyNumber)
                Text(inspection.carModel)
                Text(inspection.carVin)
                Text(inspection.carVin)
            }
            Spacer()
            WebImage(url: URL(string: inspection.photos.first?.path ?? noImageUrl))
                .resizable()
                .indicator(.activity)
                .cornerRadius(10)
                .frame(width: 100, height: 100)
        }
    }
}

struct ListInspectionsDetails: View {
    
    var inspection: Inspections
    let noImageUrl = "https://firebasestorage.googleapis.com/v0/b/altgtu-46659.appspot.com/o/placeholder%2Fplaceholder.jpeg?alt=media&token=8f554741-2bfb-41ef-82b0-fbc64f0ffdf6"
    
    var body: some View {
        VStack {
            Text(inspection.insuranceContractNumber)
            Text(inspection.carBodyNumber)
            Text(inspection.carModel)
            Text(inspection.carVin)
            Text(inspection.carVin)
            WebImage(url: URL(string: inspection.photos.first?.path ?? noImageUrl))
                .resizable()
                .indicator(.activity)
                .frame(width: 400, height: 400)
        }
    }
}
