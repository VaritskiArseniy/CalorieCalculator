import SwiftUI
import SwiftData
import PhotosUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @Environment(\.modelContext) private var context
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageDataForNewEntry: Data?
    
    @Query(sort: \FoodModel.date, order: .forward)
    private var allEntries: [FoodModel]
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                progressSection
                listSection
            }
            .padding(.horizontal, 16)
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
                .padding(16)
        }
        .alert(String(localized: "Delete Item?"),
               isPresented: $viewModel.showDeleteAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button(String(localized: "Delete"), role: .destructive) {
                viewModel.confirmDelete(context: context)
            }
        } message: {
            if let entryToDelete = viewModel.entryToDelete {
                Text(
                    String(
                        localized: "Are you sure you want to delete “\(entryToDelete.title)” ?"
                    )
                )
            }
        }
        .alert(String(localized: "Item Already Exists"),
               isPresented: $viewModel.showDuplicateAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button(String(localized: "Add Another")) {
                viewModel.confirmAddDuplicate(
                    context: context,
                    imageData: selectedImageDataForNewEntry
                )
                clearImageSelection()
            }
        } message: {
            Text(
                String(localized: "This item already exists for today. Add another one with the same name?")
            )
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            NoteSheet(
                title: $viewModel.editingTitle,
                calories: $viewModel.editingCalories,
                id: viewModel.editingEntry?.id,
                entry: viewModel.editingEntry
            ) {
                viewModel.saveFromSheet(
                    context: context,
                    imageData: selectedImageDataForNewEntry
                )
                viewModel.updateEntries(allEntries)
                clearImageSelection()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.updateEntries(allEntries)
        }
        .onChange(of: allEntries) { _, newValue in
            viewModel.updateEntries(newValue)
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.selectedImageDataForNewEntry = data
                    }
                }
            }
        }
    }
    
    private var addButton: some View {
        Button {
            viewModel.startCreating()
            clearImageSelection()
        } label: {
            Circle()
                .fill(.blue)
                .frame(width: 48, height: 48)
                .shadow(radius: 4)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                }
        }
    }
        
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(localized: "Daily Total"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(viewModel.dailyGoal) " + String(localized: "kcal goal"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(viewModel.totalCalories)")
                .font(.system(size: 40, weight: .bold))
                .contentTransition(.numericText())
                .animation(.easeInOut, value: viewModel.totalCalories)
            
            GeometryReader { geometry in
                 ZStack(alignment: .leading) {
                     Capsule()
                         .fill(Color.gray.opacity(0.25))
                         .frame(height: 14)
                         .overlay(alignment: .leading) {
                             Capsule()
                                 .fill(Color.blue)
                                 .frame(
                                    width: geometry.size.width * viewModel.progress,
                                    height: 14
                                 )
                                 .animation(.easeInOut, value: viewModel.progress)
                         }
                 }
             }
             .frame(height: 14)
         }
    }
    
    private var listSection: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(section.date.formattedFull())
                                .font(.headline)
                            Spacer()
                            Text("\(section.totalCalories) " + String(localized: "kcal"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)
                        
                        ForEach(section.entries) { entry in
                            HStack(spacing: 12) {
                                if let data = entry.imageData,
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(entry.title)
                                        .font(.body)
                                    Text("\(entry.calories) " + String(localized: "kcal"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Button {
                                        viewModel.startEditing(entry)
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundStyle(.blue)
                                    }
                                    
                                    Button {
                                        viewModel.requestDelete(entry)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.top, 8)
        }
    }
        
    private func clearImageSelection() {
        selectedItem = nil
        selectedImageDataForNewEntry = nil
    }
}
