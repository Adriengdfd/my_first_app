import Foundation
import SwiftData

@Model
final class StatisticValue {
    var id: UUID
    var labelSnapshot: String
    var fieldTypeSnapshot: StatisticFieldType
    var unitLabelSnapshot: String
    var rawValue: String
    var displayOrderSnapshot: Int

    var activityEntry: ActivityEntry?
    var statisticDefinition: StatisticDefinition?

    init(
        id: UUID = UUID(),
        labelSnapshot: String,
        fieldTypeSnapshot: StatisticFieldType,
        unitLabelSnapshot: String = "",
        rawValue: String,
        displayOrderSnapshot: Int,
        activityEntry: ActivityEntry? = nil,
        statisticDefinition: StatisticDefinition? = nil
    ) {
        self.id = id
        self.labelSnapshot = labelSnapshot
        self.fieldTypeSnapshot = fieldTypeSnapshot
        self.unitLabelSnapshot = unitLabelSnapshot
        self.rawValue = rawValue
        self.displayOrderSnapshot = displayOrderSnapshot
        self.activityEntry = activityEntry
        self.statisticDefinition = statisticDefinition
    }
}