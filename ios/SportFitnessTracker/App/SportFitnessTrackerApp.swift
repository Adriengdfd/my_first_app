import SwiftUI
import SwiftData

@main
struct SportFitnessTrackerApp: App {
    @State private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appEnvironment)
        }
        .modelContainer(appEnvironment.persistenceController.container)
    }
}