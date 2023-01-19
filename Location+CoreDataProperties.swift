//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by maxshikin on 19.01.2023.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var placemark: CLPlacemark?

}

extension Location : Identifiable {

}
