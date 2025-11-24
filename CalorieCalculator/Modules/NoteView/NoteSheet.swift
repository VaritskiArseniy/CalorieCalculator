import SwiftUI

struct NoteSheet: View {
    @Binding var title: String
    @Binding var calories: Int
    @Environment(\.dismiss) private var dismiss
    
    let id: UUID?
    let entry: FoodModel?
    var onSave: () -> Void
    
    private var isEditing: Bool {
        entry != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Title")) {
                    TextField(
                        String(localized: "Product name"),
                        text: $title
                    )
                }
                
                Section(String(localized: "Calories")) {
                        TextField(
                            String(localized: "kcal"),
                            text: Binding(
                                get: { String(calories) },
                                set: { newValue in
                                    calories = Int(newValue) ?? 0
                                }
                            )
                        )
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(
                isEditing ? String(localized: "Edit Item") : String(localized: "New Item")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(
                        isEditing ? String(localized: "Save") : String(localized: "Create")
                    ) {
                        onSave()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
