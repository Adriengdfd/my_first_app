import SwiftUI

struct FoodEditorView: View {
    @Binding var draft: FoodDraft
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Food") {
                TextField("Name", text: $draft.name)
                TextField("Default serving", text: $draft.defaultServingLabel)
            }

            Section("Nutrition per serving") {
                TextField("Calories", text: $draft.calories)
                    .keyboardType(.decimalPad)
                TextField("Protein", text: $draft.protein)
                    .keyboardType(.decimalPad)
                TextField("Carbs", text: $draft.carbs)
                    .keyboardType(.decimalPad)
                TextField("Fat", text: $draft.fat)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Food")
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