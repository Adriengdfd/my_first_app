import XCTest
@testable import SportFitnessTracker

final class SportFitnessTrackerTests: XCTestCase {
    func testDailyNutritionTotalsAccumulateEntries() {
        let food = FoodItem(
            name: "Test Food",
            defaultServingLabel: "1 bowl",
            caloriesPerServing: 100,
            proteinPerServing: 10,
            carbsPerServing: 12,
            fatPerServing: 3
        )
        let entry = NutritionSummaryService.makeEntry(from: food, servings: 2, date: .now)

        let totals = NutritionSummaryService.totals(for: [entry])

        XCTAssertEqual(totals.calories, 200)
        XCTAssertEqual(totals.protein, 20)
        XCTAssertEqual(totals.carbs, 24)
        XCTAssertEqual(totals.fat, 6)
    }
}