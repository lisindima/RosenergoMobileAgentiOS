//
//  LocationStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 05.10.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Combine
import CoreLocation

class LocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    static let shared = LocationStore()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            latitude = manager.location?.coordinate.latitude ?? 0.0
            longitude = manager.location?.coordinate.longitude ?? 0.0
            manager.startUpdatingLocation()
            manager.allowsBackgroundLocationUpdates = true
        case .notDetermined, .restricted, .denied:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        latitude = currentLocation!.coordinate.latitude
        longitude = currentLocation!.coordinate.longitude
        SessionStore.shared.updateLocation(latitude: latitude, longitude: longitude)
        print(latitude, longitude)
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
