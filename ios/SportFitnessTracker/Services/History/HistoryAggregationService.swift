import Foundation

struct ActivityHistoryItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
}

struct DailyHistorySection: Identifiable, Equatable {
    let id: Date
    let date: Date
    let nutritionTotals: DailyNutritionTotals
    let foodEntries: [FoodEntry]
    let activities: [ActivityHistoryItem]
}

enum HistoryAggregationService {
    static func buildSections(foodEntries: [FoodEntry], activityEntries: [ActivityEntry]) -> [DailyHistorySection] {
        let calendar = Calendar.current
        let allDates = Set(foodEntries.map { calendar.startOfDay(for: $0.entryDate) } + activityEntries.map { calendar.startOfDay(for: $0.activityDate) })

        return allDates
            .sorted(by: >)
            .map { date in
                let foodForDay = foodEntries.filter { calendar.isDate($0.entryDate, inSameDayAs: date) }
                let activityForDay = activityEntries
                    .filter { calendar.isDate($0.activityDate, inSameDayAs: date) }
                    .map { entry in
                        let subtitle = entry.statisticValues
                            .sorted { $0.displayOrderSnapshot < $1.displayOrderSnapshot }
                            .map { value in
                                value.unitLabelSnapshot.isEmpty
                                    ? "\(value.labelSnapshot): \(value.rawValue)"
                                    : "\(value.labelSnapshot): \(value.rawValue) \(value.unitLabelSnapshot)"
                            }
                            .joined(separator: " • ")

                        return ActivityHistoryItem(
                            id: entry.id,
                            title: entry.sportNameSnapshot,
                            subtitle: subtitle
                        )
                    }

                return DailyHistorySection(
                    id: date,
                    date: date,
                    nutritionTotals: NutritionSummaryService.totals(for: foodForDay),
                    foodEntries: foodForDay,
                    activities: activityForDay
                )
            }
    }
}