import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class HistoryViewModel {
    var sections: [DailyHistorySection] = []

    func load(context: ModelContext) {
        let foodDescriptor = FetchDescriptor<FoodEntry>(sortBy: [SortDescriptor(\.entryDate, order: .reverse)])
        let activityDescriptor = FetchDescriptor<ActivityEntry>(sortBy: [SortDescriptor(\.activityDate, order: .reverse)])

        let foods = (try? context.fetch(foodDescriptor)) ?? []
        let activities = (try? context.fetch(activityDescriptor)) ?? []

        sections = HistoryAggregationService.buildSections(foodEntries: foods, activityEntries: activities)
    }
}