import Foundation

enum ActivityValidationService {
    static func validate(profile: SportProfile, values: [UUID: String]) throws {
        let definitions = profile.statisticDefinitions.sorted { $0.displayOrder < $1.displayOrder }

        guard !definitions.isEmpty else {
            throw ValidationError.requiredField("At least one statistic")
        }

        for definition in definitions {
            let raw = values[definition.id, default: ""]

            if definition.isRequired {
                try FieldValidation.requireText(raw, field: definition.label)
            }

            if raw.isEmpty {
                continue
            }

            switch definition.fieldType {
            case .number, .duration:
                _ = try FieldValidation.parseDouble(raw, field: definition.label)
            case .choice:
                let choices = definition.validationConfig.choices
                if !choices.isEmpty && !choices.contains(raw) {
                    throw ValidationError.invalidChoice(definition.label)
                }
            case .text, .date, .boolean:
                break
            }
        }
    }

    static func makeStatisticValues(profile: SportProfile, values: [UUID: String]) -> [StatisticValue] {
        profile.statisticDefinitions
            .sorted { $0.displayOrder < $1.displayOrder }
            .compactMap { definition in
                let raw = values[definition.id, default: ""]
                if raw.isEmpty && !definition.isRequired {
                    return nil
                }

                return StatisticValue(
                    labelSnapshot: definition.label,
                    fieldTypeSnapshot: definition.fieldType,
                    unitLabelSnapshot: definition.unitLabel,
                    rawValue: raw,
                    displayOrderSnapshot: definition.displayOrder,
                    statisticDefinition: definition
                )
            }
    }
}