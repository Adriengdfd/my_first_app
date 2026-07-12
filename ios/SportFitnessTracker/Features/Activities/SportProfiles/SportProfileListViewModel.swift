import Foundation
import Observation
import SwiftData

struct SportProfileDraft: Equatable {
    var sportName: String = ""
    var definitions: [StatisticDefinitionDraft] = [StatisticDefinitionDraft()]
}

@Observable
@MainActor
final class SportProfileListViewModel {
    var profiles: [SportProfile] = []
    var errorMessage = ""

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<SportProfile>(sortBy: [SortDescriptor(\.sportName), SortDescriptor(\.version, order: .reverse)])
        profiles = ((try? context.fetch(descriptor)) ?? []).filter(\.isActive)
    }

    func makeDraft(from profile: SportProfile?) -> SportProfileDraft {
        guard let profile else {
            return SportProfileDraft()
        }

        let definitions = profile.statisticDefinitions
            .sorted { $0.displayOrder < $1.displayOrder }
            .map {
                StatisticDefinitionDraft(
                    label: $0.label,
                    fieldType: $0.fieldType,
                    unitLabel: $0.unitLabel,
                    isRequired: $0.isRequired,
                    choiceValues: $0.validationConfig.choices.joined(separator: ", ")
                )
            }

        return SportProfileDraft(sportName: profile.sportName, definitions: definitions)
    }

    func save(draft: SportProfileDraft, editing: SportProfile?, context: ModelContext) {
        do {
            try FieldValidation.requireText(draft.sportName, field: "Sport name")
            if draft.definitions.isEmpty {
                throw ValidationError.requiredField("At least one statistic")
            }

            let labels = draft.definitions.map { $0.label.trimmingCharacters(in: .whitespacesAndNewlines) }
            for label in labels {
                try FieldValidation.requireText(label, field: "Statistic label")
            }
            if Set(labels.map { $0.lowercased() }).count != labels.count {
                throw ValidationError.duplicateValue("Statistic label")
            }

            let profile: SportProfile
            if let editing {
                profile = SportProfileVersioningService.makeNextVersion(from: editing, drafts: draft.definitions)
                context.insert(profile)
            } else {
                profile = SportProfileVersioningService.createProfile(name: draft.sportName, drafts: draft.definitions)
                context.insert(profile)
            }

            profile.sportName = draft.sportName.trimmingCharacters(in: .whitespacesAndNewlines)
            try context.save()
            errorMessage = ""
            load(context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}