//
//  LocalInspections+CoreDataProperties.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 20.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//
//

import CoreData
import Foundation

public extension LocalInspections {
    @nonobjc class func fetchRequest() -> NSFetchRequest<LocalInspections> {
        NSFetchRequest<LocalInspections>(entityName: "LocalInspections")
    }
    
    @NSManaged var carBodyNumber: String
    @NSManaged var carBodyNumber2: String?
    @NSManaged var carModel: String
    @NSManaged var carModel2: String?
    @NSManaged var carRegNumber: String
    @NSManaged var carRegNumber2: String?
    @NSManaged var carVin: String
    @NSManaged var carVin2: String?
    @NSManaged var dateInspections: Date
    @NSManaged var id: UUID
    @NSManaged var insuranceContractNumber: String
    @NSManaged var insuranceContractNumber2: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var localPhotos: Set<LocalPhotos>
    @NSManaged var videoURL: URL?
}

// MARK: Generated accessors for localPhotos

public extension LocalInspections {
    @objc(addLocalPhotosObject:)
    @NSManaged func addToLocalPhotos(_ value: LocalPhotos)
    
    @objc(removeLocalPhotosObject:)
    @NSManaged func removeFromLocalPhotos(_ value: LocalPhotos)
    
    @objc(addLocalPhotos:)
    @NSManaged func addToLocalPhotos(_ values: Set<LocalPhotos>)
    
    @objc(removeLocalPhotos:)
    @NSManaged func removeFromLocalPhotos(_ values: Set<LocalPhotos>)
}
