import Foundation
import SwiftData
import PhotosUI
import Combine

final class MainViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var showDeleteAlert: Bool = false
    @Published var entryToDelete: FoodModel?
    @Published var showDuplicateAlert: Bool = false
    @Published var pendingTitle: String = ""
    @Published var pendingCalories: Int = 0
    @Published var showEditSheet: Bool = false
    @Published var editingEntry: FoodModel?
    @Published var editingTitle: String = ""
    @Published var editingCalories: Int = 0
    @Published var isCreatingNew: Bool = false
    @Published private(set) var todayEntries: [FoodModel] = []
    @Published private(set) var sections: [DayModel] = []
    @Published private(set) var totalCalories: Int = 0
    @Published private(set) var progress: Double = 0
    
    private let service = CalorieService()
    
    var dailyGoal: Int {
        service.dailyGoal
    }
    
    func updateEntries(_ allEntries: [FoodModel]) {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: allEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        let mapped: [DayModel] = grouped.map { (date, entries) in
            let sortedEntries = entries.sorted { $0.date < $1.date }
            let total = service.totalCalories(for: sortedEntries)
            return DayModel(date: date, entries: sortedEntries, totalCalories: total)
        }
        
        let sortedSections = mapped.sorted { $0.date > $1.date }
        sections = sortedSections
        
        if let todaySection = sortedSections.first(where: { calendar.isDateInToday($0.date) }) {
            todayEntries = todaySection.entries
            totalCalories = todaySection.totalCalories
        } else {
            todayEntries = []
            totalCalories = 0
        }
        
        progress = service.progress(totalCalories: totalCalories)
    }
    
    func startCreating() {
        isCreatingNew = true
        editingEntry = nil
        editingTitle = ""
        editingCalories = 0
        showEditSheet = true
    }
    
    func startEditing(_ entry: FoodModel) {
        isCreatingNew = false
        editingEntry = entry
        editingTitle = entry.title
        editingCalories = entry.calories
        showEditSheet = true
    }
    
    func saveFromSheet(
        context: ModelContext,
        imageData: Data?
    ) {
        if let editingEntry, !isCreatingNew {
            editingEntry.title = editingTitle
            editingEntry.calories = editingCalories
            try? context.save()
        } else {
            let entry = service.makeEntry(
                id: UUID(),
                title: editingTitle,
                calories: editingCalories,
                imageData: imageData
            )
            context.insert(entry)
            try? context.save()
        }
        
        showEditSheet = false
        isCreatingNew = false
    }
    
    func handleAddTapped(
        context: ModelContext,
        imageData: Data?
    ) {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard let (title, calories) = service.parseInput(trimmed) else {
            return
        }
        
        pendingTitle = title
        pendingCalories = calories
        
        if service.hasDuplicate(title: title, in: todayEntries) {
            showDuplicateAlert = true
        } else {
            addEntry(
                title: title,
                calories: calories,
                imageData: imageData,
                context: context
            )
        }
    }
    
    func confirmAddDuplicate(
        context: ModelContext,
        imageData: Data?
    ) {
        addEntry(
            title: pendingTitle,
            calories: pendingCalories,
            imageData: imageData,
            context: context
        )
        showDuplicateAlert = false
    }
    
    func requestDelete(_ entry: FoodModel) {
        entryToDelete = entry
        showDeleteAlert = true
    }
    
    func confirmDelete(context: ModelContext) {
        guard let entryToDelete else { return }
        context.delete(entryToDelete)
        try? context.save()
        self.entryToDelete = nil
        showDeleteAlert = false
    }
    
    private func addEntry(
          title: String,
          calories: Int,
          imageData: Data?,
          context: ModelContext
      ) {
          let entry = service.makeEntry(
              id: UUID(),
              title: title,
              calories: calories,
              imageData: imageData
          )
          
          context.insert(entry)
          try? context.save()
          
          inputText = ""
      }
}
