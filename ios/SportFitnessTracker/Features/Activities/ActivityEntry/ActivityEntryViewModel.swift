import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class ActivityEntryViewModel {
    var selectedDate: Date = .now
    var profiles: [SportProfile] = []
    var selectedProfileID: UUID?
    var fieldValues: [UUID: String] = [:]
    var errorMessage = ""

    var selectedProfile: SportProfile? {
        profiles.first { $0.id == selectedProfileID }
    }

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<SportProfile>(sortBy: [SortDescriptor(\.sportName)])
        profiles = ((try? context.fetch(descriptor)) ?? []).filter(\.isActive)
        if selectedProfileID == nil {
            selectedProfileID = profiles.first?.id
        }
        resetFieldValues()
    }

    func resetFieldValues() {
        fieldValues = selectedProfile?.statisticDefinitions.reduce(into: [:]) { partial, definition in
            partial[definition.id] = definition.fieldType == .boolean ? "false" : ""
        } ?? [:]
    }

    func save(context: ModelContext) {
        do {
            guard let profile = selectedProfile else {
                throw ValidationError.requiredField("Sport")
            }

            try ActivityValidationService.validate(profile: profile, values: fieldValues)
            let values = ActivityValidationService.makeStatisticValues(profile: profile, values: fieldValues)
            let activity = ActivityEntry(
                activityDate: selectedDate,
                sportNameSnapshot: profile.sportName,
                sportProfileVersionSnapshot: profile.version,
                sportProfile: profile,
                statisticValues: values
            )
            values.forEach { $0.activityEntry = activity }
            context.insert(activity)
            try context.save()
            errorMessage = ""
            resetFieldValues()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}