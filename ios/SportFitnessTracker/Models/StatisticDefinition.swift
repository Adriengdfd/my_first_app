import Foundation
import SwiftData

enum StatisticFieldType: String, Codable, CaseIterable, Identifiable {
    case number
    case text
    case duration
    case date
    case boolean
    case choice

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

struct StatisticValidationConfig: Codable, Hashable {
    var minimumValue: Double?
    var maximumValue: Double?
    var choices: [String]

    static let `default` = StatisticValidationConfig(minimumValue: nil, maximumValue: nil, choices: [])
}

@Model
final class StatisticDefinition {
    var id: UUID
    var label: String
    var fieldType: StatisticFieldType
    var unitLabel: String
    var isRequired: Bool
    var displayOrder: Int
    var validationConfig: StatisticValidationConfig
    var createdAt: Date

    var sportProfile: SportProfile?

    init(
        id: UUID = UUID(),
        label: String,
        fieldType: StatisticFieldType,
        unitLabel: String = "",
        isRequired: Bool = true,
        displayOrder: Int,
        validationConfig: StatisticValidationConfig = .default,
        createdAt: Date = .now,
        sportProfile: SportProfile? = nil
    ) {
        self.id = id
        self.label = label
        self.fieldType = fieldType
        self.unitLabel = unitLabel
        self.isRequired = isRequired
        self.displayOrder = displayOrder
        self.validationConfig = validationConfig
        self.createdAt = createdAt
        self.sportProfile = sportProfile
    }
}