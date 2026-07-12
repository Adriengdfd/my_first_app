import SwiftUI
import SwiftData

struct ActivityEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ActivityEntryViewModel()

    var body: some View {
        Form {
            Section("Activity") {
                DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                Picker("Sport", selection: $viewModel.selectedProfileID) {
                    Text("Select sport").tag(UUID?.none)
                    ForEach(viewModel.profiles) { profile in
                        Text(profile.sportName).tag(UUID?.some(profile.id))
                    }
                }
                .onChange(of: viewModel.selectedProfileID) { _, _ in
                    viewModel.resetFieldValues()
                }
            }

            if let profile = viewModel.selectedProfile {
                Section("Statistics") {
                    ForEach(profile.statisticDefinitions.sorted(by: { $0.displayOrder < $1.displayOrder })) { definition in
                        statisticField(for: definition)
                    }
                }
            } else {
                Section {
                    EmptyStateView(
                        title: "No sport selected",
                        message: "Create a sport profile before logging an activity.",
                        systemImage: "figure.run.circle"
                    )
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Section {
                    InlineMessageView(message: viewModel.errorMessage)
                }
            }

            Section {
                Button("Save Activity") {
                    viewModel.save(context: modelContext)
                }
            }
        }
        .navigationTitle("Add Activity")
        .task {
            viewModel.load(context: modelContext)
        }
    }

    @ViewBuilder
    private func statisticField(for definition: StatisticDefinition) -> some View {
        switch definition.fieldType {
        case .boolean:
            Toggle(definition.label, isOn: Binding(
                get: { viewModel.fieldValues[definition.id, default: "false"] == "true" },
                set: { viewModel.fieldValues[definition.id] = $0 ? "true" : "false" }
            ))
        case .date:
            DatePicker(
                definition.label,
                selection: Binding(
                    get: {
                        if let raw = viewModel.fieldValues[definition.id],
                           let date = AppFormatters.compactDate.date(from: raw) {
                            return date
                        }
                        return .now
                    },
                    set: { newDate in
                        viewModel.fieldValues[definition.id] = AppFormatters.compactDate.string(from: newDate)
                    }
                ),
                displayedComponents: .date
            )
        case .choice:
            Picker(definition.label, selection: Binding(
                get: { viewModel.fieldValues[definition.id, default: definition.validationConfig.choices.first ?? ""] },
                set: { viewModel.fieldValues[definition.id] = $0 }
            )) {
                ForEach(definition.validationConfig.choices, id: \.self) { choice in
                    Text(choice).tag(choice)
                }
            }
        default:
            TextField(definition.label, text: Binding(
                get: { viewModel.fieldValues[definition.id, default: ""] },
                set: { viewModel.fieldValues[definition.id] = $0 }
            ))
            .keyboardType(definition.fieldType == .number || definition.fieldType == .duration ? .decimalPad : .default)
        }
    }
}

#Preview {
    ActivityEntryView()
}