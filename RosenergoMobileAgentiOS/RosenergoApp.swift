//
//  RosenergoApp.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 26.06.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import CoreData

@main
struct WatchApp: App {
    
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var sessionStore = SessionStore()
    @StateObject var coreData = CoreData()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.rosenergo)
                .environmentObject(sessionStore)
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("scene is now active!")
                #if !os(watchOS)
                UIApplication.shared.applicationIconBadgeNumber = 0
                NotificationStore.shared.requestPermission()
                NotificationStore.shared.refreshNotificationStatus()
                #endif
                if SessionStore.shared.loginModel != nil {
                    SessionStore.shared.validateToken()
                }
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now background!")
                //coreData.saveContext()
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}

#if !os(watchOS)
class AppDelegate: NSObject, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let sessionStore = SessionStore.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        CLLocationManager().delegate = self
        return true
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var currentLoc: CLLocation!
        manager.requestWhenInUseAuthorization()
        switch manager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            currentLoc = manager.location
            sessionStore.latitude = currentLoc.coordinate.latitude
            sessionStore.longitude = currentLoc.coordinate.longitude
        case .notDetermined, .restricted, .denied:
            sessionStore.latitude = 0.0
            sessionStore.longitude = 0.0
        @unknown default:
            sessionStore.latitude = 0.0
            sessionStore.longitude = 0.0
        }
    }
}
#endif

class CoreData: ObservableObject {
    
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
