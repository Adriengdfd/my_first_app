import Foundation

struct DailyNutritionTotals: Equatable {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

enum NutritionSummaryService {
    static func makeEntry(from foodItem: FoodItem, servings: Double, date: Date) -> FoodEntry {
        FoodEntry(
            entryDate: date,
            servings: servings,
            foodNameSnapshot: foodItem.name,
            defaultServingLabelSnapshot: foodItem.defaultServingLabel,
            caloriesPerServingSnapshot: foodItem.caloriesPerServing,
            proteinPerServingSnapshot: foodItem.proteinPerServing,
            carbsPerServingSnapshot: foodItem.carbsPerServing,
            fatPerServingSnapshot: foodItem.fatPerServing,
            foodItem: foodItem
        )
    }

    static func totals(for entries: [FoodEntry]) -> DailyNutritionTotals {
        entries.reduce(into: DailyNutritionTotals()) { partial, entry in
            partial.calories += entry.caloriesPerServingSnapshot * entry.servings
            partial.protein += entry.proteinPerServingSnapshot * entry.servings
            partial.carbs += entry.carbsPerServingSnapshot * entry.servings
            partial.fat += entry.fatPerServingSnapshot * entry.servings
        }
    }
}