import Foundation

struct DayModel: Identifiable {
    let id = UUID()
    let date: Date
    let entries: [FoodModel]
    let totalCalories: Int
}
