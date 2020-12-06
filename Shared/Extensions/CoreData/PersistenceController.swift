//
//  PersistenceController.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 22.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    
    init() {
        let storeURL = URL.storeURL(for: "group.darkfox.rosenergo", database: "RosenergoMobileAgentiOS")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        container = NSPersistentCloudKitContainer(name: "RosenergoMobileAgentiOS")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

extension URL {
    static func storeURL(for appGroup: String, database: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(database).sqlite")
    }
}
