import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var entryDate: Date
    var servings: Double
    var foodNameSnapshot: String
    var defaultServingLabelSnapshot: String
    var caloriesPerServingSnapshot: Double
    var proteinPerServingSnapshot: Double
    var carbsPerServingSnapshot: Double
    var fatPerServingSnapshot: Double
    var createdAt: Date

    var foodItem: FoodItem?

    init(
        id: UUID = UUID(),
        entryDate: Date,
        servings: Double,
        foodNameSnapshot: String,
        defaultServingLabelSnapshot: String,
        caloriesPerServingSnapshot: Double,
        proteinPerServingSnapshot: Double,
        carbsPerServingSnapshot: Double,
        fatPerServingSnapshot: Double,
        createdAt: Date = .now,
        foodItem: FoodItem? = nil
    ) {
        self.id = id
        self.entryDate = entryDate
        self.servings = servings
        self.foodNameSnapshot = foodNameSnapshot
        self.defaultServingLabelSnapshot = defaultServingLabelSnapshot
        self.caloriesPerServingSnapshot = caloriesPerServingSnapshot
        self.proteinPerServingSnapshot = proteinPerServingSnapshot
        self.carbsPerServingSnapshot = carbsPerServingSnapshot
        self.fatPerServingSnapshot = fatPerServingSnapshot
        self.createdAt = createdAt
        self.foodItem = foodItem
    }
}