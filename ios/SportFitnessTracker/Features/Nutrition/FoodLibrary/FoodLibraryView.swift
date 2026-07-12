import SwiftUI
import SwiftData

struct FoodLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FoodLibraryViewModel()
    @State private var draft = FoodDraft()
    @State private var editingItem: FoodItem?
    @State private var isPresentingEditor = false

    var body: some View {
        List {
            if !viewModel.errorMessage.isEmpty {
                InlineMessageView(message: viewModel.errorMessage)
                    .listRowSeparator(.hidden)
            }

            if viewModel.foodItems.isEmpty {
                EmptyStateView(
                    title: "No foods yet",
                    message: "Create your first food item to start logging meals.",
                    systemImage: "fork.knife.circle"
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.foodItems) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                        Text("\(AppFormatters.string(for: item.caloriesPerServing)) kcal • \(AppFormatters.string(for: item.proteinPerServing)) P • \(AppFormatters.string(for: item.carbsPerServing)) C • \(AppFormatters.string(for: item.fatPerServing)) F")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Serving: \(item.defaultServingLabel)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button("Edit") {
                            editingItem = item
                            draft = viewModel.makeDraft(from: item)
                            isPresentingEditor = true
                        }
                        .tint(.blue)

                        Button("Archive", role: .destructive) {
                            viewModel.archive(item, context: modelContext)
                        }
                    }
                }
            }
        }
        .navigationTitle("Food Library")
        .toolbar {
            Button {
                editingItem = nil
                draft = FoodDraft()
                isPresentingEditor = true
            } label: {
                Label("Add Food", systemImage: "plus")
            }
        }
        .task {
            viewModel.load(context: modelContext)
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                FoodEditorView(draft: $draft) {
                    viewModel.save(draft: draft, editing: editingItem, context: modelContext)
                    if viewModel.errorMessage.isEmpty {
                        isPresentingEditor = false
                    }
                }
            }
        }
    }
}

#Preview {
    FoodLibraryView()
}