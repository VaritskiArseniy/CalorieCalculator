
import Foundation
import SwiftData

final class CalorieService {
    
    let dailyGoal: Int = 2000
        
    func todayEntries(from allEntries: [FoodModel]) -> [FoodModel] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    func totalCalories(for entries: [FoodModel]) -> Int {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    func progress(totalCalories: Int) -> Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(totalCalories) / Double(dailyGoal), 1.0)
    }
        
    func parseInput(_ text: String) -> (String, Int)? {
        let parts = text.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        
        guard let last = parts.last,
              let calories = Int(last) else {
            return nil
        }
        
        let nameParts = parts.dropLast()
        let name = nameParts.joined(separator: " ")
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        return (name, calories)
    }
        
    func hasDuplicate(title: String, in entries: [FoodModel]) -> Bool {
        entries.contains {
            $0.title.compare(title, options: .caseInsensitive) == .orderedSame
        }
    }
        
    func makeEntry(
        id: UUID,
        title: String,
        calories: Int,
        imageData: Data?
    ) -> FoodModel {
        FoodModel(
            id: UUID(),
            title: title,
            calories: calories,
            date: Date(),
            imageData: imageData
        )
    }
}
