import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var defaultServingLabel: String
    var caloriesPerServing: Double
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.foodItem)
    var entries: [FoodEntry]

    init(
        id: UUID = UUID(),
        name: String,
        defaultServingLabel: String,
        caloriesPerServing: Double,
        proteinPerServing: Double,
        carbsPerServing: Double,
        fatPerServing: Double,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isArchived: Bool = false,
        entries: [FoodEntry] = []
    ) {
        self.id = id
        self.name = name
        self.defaultServingLabel = defaultServingLabel
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.entries = entries
    }
}