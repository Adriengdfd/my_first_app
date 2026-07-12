import SwiftUI

struct NutritionTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Nutrition") {
                    NavigationLink("Food Library") {
                        FoodLibraryView()
                    }

                    NavigationLink("Daily Log") {
                        DailyNutritionLogView()
                    }
                }
            }
            .navigationTitle("Nutrition")
        }
    }
}

#Preview {
    NutritionTabView()
}