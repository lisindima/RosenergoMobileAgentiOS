//
//  MapView.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 16.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var latitude: Double
    var longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setCenter(coordinate, animated: false)
        mapView.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
        let inspections = MKPointAnnotation()
        inspections.coordinate = coordinate
        mapView.addAnnotation(inspections)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
