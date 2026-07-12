import SwiftUI

struct DailyHistoryView: View {
    let section: DailyHistorySection

    var body: some View {
        List {
            Section("Nutrition Totals") {
                LabeledContent("Calories", value: AppFormatters.string(for: section.nutritionTotals.calories))
                LabeledContent("Protein", value: AppFormatters.string(for: section.nutritionTotals.protein))
                LabeledContent("Carbs", value: AppFormatters.string(for: section.nutritionTotals.carbs))
                LabeledContent("Fat", value: AppFormatters.string(for: section.nutritionTotals.fat))
            }

            Section("Food Entries") {
                if section.foodEntries.isEmpty {
                    Text("No food entries")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(section.foodEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.foodNameSnapshot)
                                .font(.headline)
                            Text("\(AppFormatters.string(for: entry.servings)) × \(entry.defaultServingLabelSnapshot)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Activities") {
                if section.activities.isEmpty {
                    Text("No activities")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(section.activities) { activity in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .font(.headline)
                            Text(activity.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(AppFormatters.date.string(from: section.date))
    }
}