import Foundation
import SwiftData

@Model
final class ActivityEntry {
    var id: UUID
    var activityDate: Date
    var sportNameSnapshot: String
    var sportProfileVersionSnapshot: Int
    var createdAt: Date

    var sportProfile: SportProfile?

    @Relationship(deleteRule: .cascade, inverse: \StatisticValue.activityEntry)
    var statisticValues: [StatisticValue]

    init(
        id: UUID = UUID(),
        activityDate: Date,
        sportNameSnapshot: String,
        sportProfileVersionSnapshot: Int,
        createdAt: Date = .now,
        sportProfile: SportProfile? = nil,
        statisticValues: [StatisticValue] = []
    ) {
        self.id = id
        self.activityDate = activityDate
        self.sportNameSnapshot = sportNameSnapshot
        self.sportProfileVersionSnapshot = sportProfileVersionSnapshot
        self.createdAt = createdAt
        self.sportProfile = sportProfile
        self.statisticValues = statisticValues
    }
}