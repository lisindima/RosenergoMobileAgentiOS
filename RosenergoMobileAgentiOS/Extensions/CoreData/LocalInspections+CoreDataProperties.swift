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

extension LocalInspections {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalInspections> {
        NSFetchRequest<LocalInspections>(entityName: "LocalInspections")
    }
    
    @NSManaged public var carBodyNumber: String
    @NSManaged public var carBodyNumber2: String?
    @NSManaged public var carModel: String
    @NSManaged public var carModel2: String?
    @NSManaged public var carRegNumber: String
    @NSManaged public var carRegNumber2: String?
    @NSManaged public var carVin: String
    @NSManaged public var carVin2: String?
    @NSManaged public var dateInspections: Date
    @NSManaged public var id: UUID
    @NSManaged public var insuranceContractNumber: String
    @NSManaged public var insuranceContractNumber2: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var localPhotos: Set<LocalPhotos>
    @NSManaged public var videoURL: URL?
    
    public var arrayPhoto: [LocalPhotos] {
        let set = localPhotos
        return set.sorted {
            $0.id < $1.id
        }
    }
}

// MARK: Generated accessors for localPhotos

extension LocalInspections {
    @objc(addLocalPhotosObject:)
    @NSManaged public func addToLocalPhotos(_ value: LocalPhotos)
    
    @objc(removeLocalPhotosObject:)
    @NSManaged public func removeFromLocalPhotos(_ value: LocalPhotos)
    
    @objc(addLocalPhotos:)
    @NSManaged public func addToLocalPhotos(_ values: NSSet)
    
    @objc(removeLocalPhotos:)
    @NSManaged public func removeFromLocalPhotos(_ values: NSSet)
}
