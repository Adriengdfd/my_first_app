import SwiftUI
import SwiftData

struct DailyNutritionLogView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DailyNutritionLogViewModel()

    var body: some View {
        List {
            Section("Date") {
                DatePicker("Entry date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .onChange(of: viewModel.selectedDate) { _, _ in
                        viewModel.reloadEntries(context: modelContext)
                    }
            }

            Section("Add Food") {
                Picker("Food", selection: $viewModel.selectedFoodItemID) {
                    Text("Select food").tag(UUID?.none)
                    ForEach(viewModel.foodItems) { item in
                        Text(item.name).tag(UUID?.some(item.id))
                    }
                }

                TextField("Servings", text: $viewModel.servingsText)
                    .keyboardType(.decimalPad)

                Button("Add to Day") {
                    viewModel.addEntry(context: modelContext)
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Section {
                    InlineMessageView(message: viewModel.errorMessage)
                }
            }

            Section("Totals") {
                LabeledContent("Calories", value: AppFormatters.string(for: viewModel.totals.calories))
                LabeledContent("Protein", value: AppFormatters.string(for: viewModel.totals.protein))
                LabeledContent("Carbs", value: AppFormatters.string(for: viewModel.totals.carbs))
                LabeledContent("Fat", value: AppFormatters.string(for: viewModel.totals.fat))
            }

            Section("Entries") {
                if viewModel.entries.isEmpty {
                    EmptyStateView(
                        title: "No meals logged",
                        message: "Add food entries for this day.",
                        systemImage: "list.bullet.rectangle"
                    )
                } else {
                    ForEach(viewModel.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.foodNameSnapshot)
                                .font(.headline)
                            Text("\(AppFormatters.string(for: entry.servings)) × \(entry.defaultServingLabelSnapshot)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                viewModel.remove(entry, context: modelContext)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Daily Log")
        .task {
            viewModel.load(context: modelContext)
        }
    }
}

#Preview {
    DailyNutritionLogView()
}