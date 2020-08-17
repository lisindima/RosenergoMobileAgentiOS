//
//  LinkDetails.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 31.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Alamofire
import AVKit
import CoreLocation
import SwiftUI
import URLImage

struct LinkDetails: View {
    @EnvironmentObject private var sessionStore: SessionStore

    @Environment(\.presentationMode) private var presentationMode

    @State private var presentMapActionSheet: Bool = false
    @State private var address: String?
    @State private var inspection: LinkInspections?
    @State private var loadAddress: Bool = false

    func getInspections() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: sessionStore.loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(sessionStore.serverURL + "inspection" + "/" + "\(sessionStore.isOpenUrlId!)", method: .get, headers: headers)
            .validate()
            .responseDecodable(of: LinkInspections.self) { [self] response in
                switch response.result {
                case .success:
                    guard let inspectionsResponse = response.value else { return }
                    inspection = inspectionsResponse
                    loadAddress = true
                case let .failure(error):
                    presentationMode.wrappedValue.dismiss()
                    debugPrint(error)
                }
            }
    }

    var body: some View {
        NavigationView {
            Form {
                if inspection?.video != nil {
                    Section(header: Text("Видео").fontWeight(.bold)) {
                        VideoPlayer(player: AVPlayer(url: URL(string: inspection!.video!)!))
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical, 8)
                    }
                }
                Section(header: Text("Дата загрузки осмотра").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "timer",
                        imageColor: .rosenergo,
                        title: inspection?.createdAt.dataInspection(local: false)
                    )
                }
                Section(header: Text(inspection?.carModel2 != nil ? "Первый автомобиль" : "Информация").fontWeight(.bold)) {
                    SectionItem(
                        imageName: "doc.plaintext",
                        imageColor: .rosenergo,
                        subTitle: "Страховой полис",
                        title: inspection?.insuranceContractNumber
                    )
                    SectionItem(
                        imageName: "car",
                        imageColor: .rosenergo,
                        subTitle: "Модель автомобиля",
                        title: inspection?.carModel
                    )
                    SectionItem(
                        imageName: "rectangle",
                        imageColor: .rosenergo,
                        subTitle: "Регистрационный номер",
                        title: inspection?.carRegNumber
                    )
                    SectionItem(
                        imageName: "v.circle",
                        imageColor: .rosenergo,
                        subTitle: "VIN",
                        title: inspection?.carVin
                    )
                    SectionItem(
                        imageName: "textformat.123",
                        imageColor: .rosenergo,
                        subTitle: "Номер кузова",
                        title: inspection?.carBodyNumber
                    )
                }
                if inspection?.carModel2 != nil {
                    Section(header: Text("Второй автомобиль").fontWeight(.bold)) {
                        SectionItem(
                            imageName: "doc.plaintext",
                            imageColor: .rosenergo,
                            subTitle: "Страховой полис",
                            title: inspection?.insuranceContractNumber2
                        )
                        SectionItem(
                            imageName: "car",
                            imageColor: .rosenergo,
                            subTitle: "Модель автомобиля",
                            title: inspection?.carModel2
                        )
                        SectionItem(
                            imageName: "rectangle",
                            imageColor: .rosenergo,
                            subTitle: "Регистрационный номер",
                            title: inspection?.carRegNumber2
                        )
                        SectionItem(
                            imageName: "v.circle",
                            imageColor: .rosenergo,
                            subTitle: "VIN",
                            title: inspection?.carVin2
                        )
                        SectionItem(
                            imageName: "textformat.123",
                            imageColor: .rosenergo,
                            subTitle: "Номер кузова",
                            title: inspection?.carBodyNumber2
                        )
                    }
                }
                Section(header: Text("Место проведения осмотра").fontWeight(.bold)) {
                    Button(action: {
                        presentMapActionSheet = true
                    }) {
                        SectionItem(
                            imageName: "map",
                            imageColor: .rosenergo,
                            title: address
                        )
                    }
                }
            }
            .navigationTitle("Осмотр: \(sessionStore.isOpenUrlId!)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Закрыть")
                    }
                }
            }
            .actionSheet(isPresented: $presentMapActionSheet) {
                ActionSheet(title: Text("Выберите приложение"), message: Text("В каком приложение вы хотите открыть это местоположение?"), buttons: [.default(Text("Apple Maps")) {
                    UIApplication.shared.open(URL(string: "https://maps.apple.com/?daddr=\(inspection!.latitude),\(inspection!.longitude)")!)
                }, .default(Text("Яндекс.Карты")) {
                    UIApplication.shared.open(URL(string: "yandexmaps://maps.yandex.ru/?pt=\(inspection!.longitude),\(inspection!.latitude)")!)
                }, .cancel()])
            }
            .onChange(of: loadAddress) { _ in
                let location = CLLocation(latitude: inspection!.latitude, longitude: inspection!.longitude)
                location.geocode { placemark, error in
                    if let error = error as? CLError {
                        print("CLError:", error)
                        return
                    } else if let placemark = placemark?.first {
                        address = "\(placemark.country ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.name ?? "")"
                    }
                }
            }
            .onAppear {
                getInspections()
            }
        }
    }
}
