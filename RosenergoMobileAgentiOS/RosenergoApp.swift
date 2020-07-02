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
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var sessionStore = SessionStore()
    @StateObject var coreData = CoreData()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionStore)
                .environment(\.managedObjectContext, coreData.persistentContainer.viewContext)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("scene is now active!")
                if SessionStore.shared.loginModel != nil {
                    SessionStore.shared.validateToken()
                }
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now background!")
                coreData.saveContext()
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}


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
