
import Foundation
import SwiftData

@Model
final class FoodModel {
    @Attribute(.unique)
    var id: UUID
    var title: String
    var calories: Int
    var date: Date
    var imageData: Data?
    
    init(
        id: UUID,
        title: String,
        calories: Int,
        date: Date,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.calories = calories
        self.date = date
        self.imageData = imageData
    }
}
