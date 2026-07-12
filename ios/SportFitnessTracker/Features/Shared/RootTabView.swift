import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NutritionTabView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }

            ActivitiesTabView()
                .tabItem {
                    Label("Activities", systemImage: "figure.run")
                }

            HistoryTabView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    RootTabView()
}