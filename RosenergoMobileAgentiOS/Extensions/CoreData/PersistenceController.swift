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
        container = NSPersistentCloudKitContainer(name: "RosenergoMobileAgentiOS")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
