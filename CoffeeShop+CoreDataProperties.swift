

import Foundation
import CoreData


extension CoffeeShop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoffeeShop> {
        return NSFetchRequest<CoffeeShop>(entityName: "CoffeeShop")
    }

    @NSManaged public var address: String?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var rating: Int16
    @NSManaged public var type: String?
    @NSManaged public var drinks: NSSet?
    @NSManaged public var roastingLevel: Int16
    @NSManaged public var intensityLevel: Float
    @NSManaged public var acidityLevel: Int16

}

// MARK: Generated accessors for drinks
extension CoffeeShop {

    @objc(addDrinksObject:)
    @NSManaged public func addToDrinks(_ value: Drink)

    @objc(removeDrinksObject:)
    @NSManaged public func removeFromDrinks(_ value: Drink)

    @objc(addDrinks:)
    @NSManaged public func addToDrinks(_ values: NSSet)

    @objc(removeDrinks:)
    @NSManaged public func removeFromDrinks(_ values: NSSet)

}

extension CoffeeShop : Identifiable {

}
