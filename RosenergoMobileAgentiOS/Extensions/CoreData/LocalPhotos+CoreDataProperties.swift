//
//  LocalPhotos+CoreDataProperties.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 20.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//
//

import Foundation
import CoreData


extension LocalPhotos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalPhotos> {
        return NSFetchRequest<LocalPhotos>(entityName: "LocalPhotos")
    }

    @NSManaged public var id: Int16
    @NSManaged public var photosData: Data?
    @NSManaged public var localInspections: LocalInspections?
}
