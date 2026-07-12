import SwiftUI

struct ActivitiesTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Activities") {
                    NavigationLink("Sports") {
                        SportProfileListView()
                    }

                    NavigationLink("Add Activity") {
                        ActivityEntryView()
                    }
                }
            }
            .navigationTitle("Activities")
        }
    }
}

#Preview {
    ActivitiesTabView()
}