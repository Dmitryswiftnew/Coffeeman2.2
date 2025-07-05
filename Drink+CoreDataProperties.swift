
import Foundation
import CoreData


extension Drink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drink> {
        return NSFetchRequest<Drink>(entityName: "Drink")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var comment: String?
    @NSManaged public var coffeeShop: CoffeeShop?

}

extension Drink : Identifiable {

}
