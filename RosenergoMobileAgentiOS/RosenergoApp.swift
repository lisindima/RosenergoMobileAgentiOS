//
//  RosenergoApp.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreData
import CoreLocation

@main
struct WatchApp: App {
    
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var sessionStore = SessionStore.shared
    @StateObject var coreData = CoreData.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
        }
    }
}

#if !os(watchOS)
class AppDelegate: NSObject, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let sessionStore = SessionStore.shared
    lazy var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return true
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus()
        var currentLoc: CLLocation
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            currentLoc = manager.location ?? CLLocation(latitude: 0.0, longitude: 0.0)
            sessionStore.latitude = currentLoc.coordinate.latitude
            sessionStore.longitude = currentLoc.coordinate.longitude
        case .notDetermined, .restricted, .denied:
            sessionStore.latitude = 0.0
            sessionStore.longitude = 0.0
        @unknown default:
            sessionStore.latitude = 0.0
            sessionStore.longitude = 0.0
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
}
#endif

class CoreData: ObservableObject {
    
    static let shared = CoreData()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "RosenergoMobileAgentiOS")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
