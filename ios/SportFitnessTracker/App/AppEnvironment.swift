import Foundation
import Observation

@Observable
final class AppEnvironment {
    let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = PersistenceController()) {
        self.persistenceController = persistenceController
    }
}