import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    let container: ModelContainer

    init(inMemory: Bool = false) {
        let schema = Schema([
            FoodItem.self,
            FoodEntry.self,
            SportProfile.self,
            StatisticDefinition.self,
            ActivityEntry.self,
            StatisticValue.self,
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error.localizedDescription)")
        }
    }
}