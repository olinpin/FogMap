//
//  PastLocations+CoreDataProperties.swift
//  FogMap
//
//  Created by Oliver Hnát on 03.08.2024.
//
//

import Foundation
import CoreData


extension PastLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PastLocations> {
        return NSFetchRequest<PastLocations>(entityName: "PastLocations")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var timestamp: Int64


}

extension PastLocations : Identifiable {

}
