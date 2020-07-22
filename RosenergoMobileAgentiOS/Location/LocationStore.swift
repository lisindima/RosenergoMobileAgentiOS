//
//  LocationStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 22.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Combine
import CoreLocation

class LocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocation?
    
    private let manager = CLLocationManager()
    
    static let shared = LocationStore()
    
    func getLocation() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            currentLocation = manager.location ?? CLLocation(latitude: 0.0, longitude: 0.0)
        case .notDetermined, .restricted, .denied:
            currentLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        @unknown default:
            currentLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        }
        
        let accuracyAuthorization = manager.accuracyAuthorization
        switch accuracyAuthorization {
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Rosenergo")
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}
