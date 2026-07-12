import Foundation
import Observation
import SwiftData

struct FoodDraft: Equatable {
    var name: String = ""
    var defaultServingLabel: String = ""
    var calories: String = ""
    var protein: String = ""
    var carbs: String = ""
    var fat: String = ""
}

@Observable
@MainActor
final class FoodLibraryViewModel {
    var foodItems: [FoodItem] = []
    var errorMessage = ""

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<FoodItem>(sortBy: [SortDescriptor(\.name)])
        foodItems = (try? context.fetch(descriptor))?.filter { !$0.isArchived } ?? []
    }

    func save(draft: FoodDraft, editing: FoodItem?, context: ModelContext) {
        do {
            try FieldValidation.requireText(draft.name, field: "Food name")
            try FieldValidation.requireText(draft.defaultServingLabel, field: "Default serving")

            let otherNames = foodItems
                .filter { $0.id != editing?.id }
                .map(\.name)
            try FieldValidation.ensureUnique(draft.name, in: otherNames, field: "Food name")

            let calories = try FieldValidation.parseDouble(draft.calories, field: "Calories")
            let protein = try FieldValidation.parseDouble(draft.protein, field: "Protein")
            let carbs = try FieldValidation.parseDouble(draft.carbs, field: "Carbs")
            let fat = try FieldValidation.parseDouble(draft.fat, field: "Fat")

            try FieldValidation.requireNonNegative(calories, field: "Calories")
            try FieldValidation.requireNonNegative(protein, field: "Protein")
            try FieldValidation.requireNonNegative(carbs, field: "Carbs")
            try FieldValidation.requireNonNegative(fat, field: "Fat")

            let item = editing ?? FoodItem(
                name: draft.name,
                defaultServingLabel: draft.defaultServingLabel,
                caloriesPerServing: calories,
                proteinPerServing: protein,
                carbsPerServing: carbs,
                fatPerServing: fat
            )

            item.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            item.defaultServingLabel = draft.defaultServingLabel.trimmingCharacters(in: .whitespacesAndNewlines)
            item.caloriesPerServing = calories
            item.proteinPerServing = protein
            item.carbsPerServing = carbs
            item.fatPerServing = fat
            item.updatedAt = .now

            if editing == nil {
                context.insert(item)
            }

            try context.save()
            errorMessage = ""
            load(context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func archive(_ item: FoodItem, context: ModelContext) {
        item.isArchived = true
        item.updatedAt = .now
        try? context.save()
        load(context: context)
    }

    func makeDraft(from item: FoodItem?) -> FoodDraft {
        guard let item else {
            return FoodDraft()
        }

        return FoodDraft(
            name: item.name,
            defaultServingLabel: item.defaultServingLabel,
            calories: AppFormatters.string(for: item.caloriesPerServing),
            protein: AppFormatters.string(for: item.proteinPerServing),
            carbs: AppFormatters.string(for: item.carbsPerServing),
            fat: AppFormatters.string(for: item.fatPerServing)
        )
    }
}