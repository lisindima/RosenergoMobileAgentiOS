//
//  LocationStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 22.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Combine
import CoreLocation
import SwiftUI

class LocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    static let shared = LocationStore()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            latitude = manager.location?.coordinate.latitude ?? 0.0
            longitude = manager.location?.coordinate.longitude ?? 0.0
            manager.startUpdatingLocation()
            switch manager.accuracyAuthorization {
            case .fullAccuracy:
                break
            case .reducedAccuracy:
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Rosenergo")
            default:
                break
            }
        case .notDetermined, .restricted, .denied:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        latitude = currentLocation!.coordinate.latitude
        longitude = currentLocation!.coordinate.longitude
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        log(error.localizedDescription)
    }
}

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(self, preferredLocale: .init(identifier: "ru"), completionHandler: completion)
    }
}
