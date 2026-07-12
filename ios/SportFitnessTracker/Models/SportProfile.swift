import Foundation
import SwiftData

@Model
final class SportProfile {
    var id: UUID
    var sportName: String
    var version: Int
    var baseProfileId: UUID
    var isActive: Bool
    var createdAt: Date
    var supersededAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \StatisticDefinition.sportProfile)
    var statisticDefinitions: [StatisticDefinition]

    @Relationship(deleteRule: .nullify, inverse: \ActivityEntry.sportProfile)
    var activityEntries: [ActivityEntry]

    init(
        id: UUID = UUID(),
        sportName: String,
        version: Int = 1,
        baseProfileId: UUID? = nil,
        isActive: Bool = true,
        createdAt: Date = .now,
        supersededAt: Date? = nil,
        statisticDefinitions: [StatisticDefinition] = [],
        activityEntries: [ActivityEntry] = []
    ) {
        self.id = id
        self.sportName = sportName
        self.version = version
        self.baseProfileId = baseProfileId ?? id
        self.isActive = isActive
        self.createdAt = createdAt
        self.supersededAt = supersededAt
        self.statisticDefinitions = statisticDefinitions
        self.activityEntries = activityEntries
    }
}