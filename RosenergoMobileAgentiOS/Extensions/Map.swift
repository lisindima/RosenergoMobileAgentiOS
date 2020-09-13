//
//  Map.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 07.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: View {
    @State private var address: String?
    @State private var pins: [Pin] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var latitude: Double
    var longitude: Double
    
    private func loadData() {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        pins.append(Pin(coordinate: .init(latitude: latitude, longitude: longitude)))
        let location = CLLocation(latitude: latitude, longitude: longitude)
        location.geocode { placemark, error in
            if let error = error {
                log(error)
                return
            } else if let placemark = placemark?.first {
                address = "\(placemark.country ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.name ?? "")"
            }
        }
    }
    
    var body: some View {
        SectionLink(
            imageName: "map",
            imageColor: .rosenergo,
            title: address,
            titleColor: .primary,
            destination: URL(string: "yandexmaps://maps.yandex.ru/?pt=\(longitude),\(latitude)")!
        )
        Map(coordinateRegion: $region, annotationItems: pins) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .rosenergo)
        }
        .frame(height: 200)
        .cornerRadius(8)
        .padding(.vertical)
        .onAppear(perform: loadData)
    }
}

struct Pin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
