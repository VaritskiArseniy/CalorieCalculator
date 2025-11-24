import SwiftUI
import PhotosUI

struct NoteSheet: View {
    @Binding var title: String
    @Binding var calories: Int
    @Environment(\.dismiss) private var dismiss
    
    let id: UUID?
    let entry: FoodModel?
    
    var onSave: (Data?) -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    
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
                
                Section(String(localized: "Photo")) {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo")
                            Text(String(localized: "Choose photo"))
                        }
                    }
                    
                    if let data = imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else if let existingData = entry?.imageData,
                              let uiImage = UIImage(data: existingData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
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
                        onSave(imageData ?? entry?.imageData)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let existingData = entry?.imageData {
                imageData = existingData
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else {
                imageData = nil
                return
            }
            
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.imageData = data
                    }
                }
            }
        }
    }
}
