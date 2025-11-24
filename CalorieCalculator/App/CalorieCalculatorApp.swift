
import SwiftUI
import SwiftData

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [FoodModel.self])
    }
}
