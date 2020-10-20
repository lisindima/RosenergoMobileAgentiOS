//
//  LocalPhotos+CoreDataProperties.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 20.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//
//

import CoreData
import Foundation

public extension LocalPhotos {
    @nonobjc class func fetchRequest() -> NSFetchRequest<LocalPhotos> {
        NSFetchRequest<LocalPhotos>(entityName: "LocalPhotos")
    }
    
    @NSManaged var id: Int16
    @NSManaged var photosData: Data
    @NSManaged var localInspections: LocalInspections
}
