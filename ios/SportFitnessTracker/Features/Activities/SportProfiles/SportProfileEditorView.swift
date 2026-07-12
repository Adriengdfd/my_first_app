import SwiftUI

struct SportProfileEditorView: View {
    @Binding var draft: SportProfileDraft
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Sport") {
                TextField("Sport name", text: $draft.sportName)
            }

            Section("Statistics") {
                ForEach($draft.definitions) { $definition in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Label", text: $definition.label)
                        Picker("Field Type", selection: $definition.fieldType) {
                            ForEach(StatisticFieldType.allCases) { fieldType in
                                Text(fieldType.displayName).tag(fieldType)
                            }
                        }
                        TextField("Unit label", text: $definition.unitLabel)
                        Toggle("Required", isOn: $definition.isRequired)
                        if definition.fieldType == .choice {
                            TextField("Choices (comma separated)", text: $definition.choiceValues)
                        }
                    }
                }
                .onDelete { offsets in
                    draft.definitions.remove(atOffsets: offsets)
                }

                Button("Add Statistic") {
                    draft.definitions.append(StatisticDefinitionDraft())
                }
            }
        }
        .navigationTitle("Sport Profile")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave()
                }
            }
        }
    }
}