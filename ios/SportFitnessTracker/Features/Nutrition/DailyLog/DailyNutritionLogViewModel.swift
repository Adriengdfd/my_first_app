import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class DailyNutritionLogViewModel {
    var selectedDate: Date = .now
    var foodItems: [FoodItem] = []
    var entries: [FoodEntry] = []
    var selectedFoodItemID: UUID?
    var servingsText: String = "1"
    var totals = DailyNutritionTotals()
    var errorMessage = ""

    func load(context: ModelContext) {
        let foodDescriptor = FetchDescriptor<FoodItem>(sortBy: [SortDescriptor(\.name)])
        foodItems = ((try? context.fetch(foodDescriptor)) ?? []).filter { !$0.isArchived }
        reloadEntries(context: context)
    }

    func reloadEntries(context: ModelContext) {
        let descriptor = FetchDescriptor<FoodEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let fetched = try? context.fetch(descriptor)
        entries = (fetched ?? []).filter { Calendar.current.isDate($0.entryDate, inSameDayAs: selectedDate) }
        totals = NutritionSummaryService.totals(for: entries)
    }

    func addEntry(context: ModelContext) {
        do {
            guard let selectedFoodItemID,
                  let foodItem = foodItems.first(where: { $0.id == selectedFoodItemID }) else {
                throw ValidationError.requiredField("Food")
            }

            let servings = try FieldValidation.parseDouble(servingsText, field: "Servings")
            try FieldValidation.requireGreaterThanZero(servings, field: "Servings")

            let entry = NutritionSummaryService.makeEntry(from: foodItem, servings: servings, date: selectedDate)
            context.insert(entry)
            try context.save()
            servingsText = "1"
            errorMessage = ""
            reloadEntries(context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ entry: FoodEntry, context: ModelContext) {
        context.delete(entry)
        try? context.save()
        reloadEntries(context: context)
    }
}