import Foundation

struct StatisticDefinitionDraft: Identifiable, Equatable {
    var id: UUID = UUID()
    var label: String = ""
    var fieldType: StatisticFieldType = .number
    var unitLabel: String = ""
    var isRequired: Bool = true
    var choiceValues: String = ""
}

enum SportProfileVersioningService {
    static func makeDefinitions(from drafts: [StatisticDefinitionDraft]) -> [StatisticDefinition] {
        drafts.enumerated().map { index, draft in
            let choices = draft.choiceValues
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            return StatisticDefinition(
                label: draft.label.trimmingCharacters(in: .whitespacesAndNewlines),
                fieldType: draft.fieldType,
                unitLabel: draft.unitLabel.trimmingCharacters(in: .whitespacesAndNewlines),
                isRequired: draft.isRequired,
                displayOrder: index,
                validationConfig: StatisticValidationConfig(choices: choices)
            )
        }
    }

    static func createProfile(name: String, drafts: [StatisticDefinitionDraft]) -> SportProfile {
        let profile = SportProfile(sportName: name.trimmingCharacters(in: .whitespacesAndNewlines))
        let definitions = makeDefinitions(from: drafts)
        definitions.forEach { $0.sportProfile = profile }
        profile.statisticDefinitions = definitions
        return profile
    }

    static func makeNextVersion(from existing: SportProfile, drafts: [StatisticDefinitionDraft]) -> SportProfile {
        existing.isActive = false
        existing.supersededAt = .now

        let next = SportProfile(
            sportName: existing.sportName,
            version: existing.version + 1,
            baseProfileId: existing.baseProfileId
        )
        let definitions = makeDefinitions(from: drafts)
        definitions.forEach { $0.sportProfile = next }
        next.statisticDefinitions = definitions
        return next
    }
}