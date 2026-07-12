import SwiftUI
import SwiftData

struct HistoryHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        List {
            if viewModel.sections.isEmpty {
                EmptyStateView(
                    title: "No history yet",
                    message: "Food and activity entries will appear here by day.",
                    systemImage: "clock.badge.questionmark"
                )
            } else {
                ForEach(viewModel.sections) { section in
                    NavigationLink {
                        DailyHistoryView(section: section)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppFormatters.date.string(from: section.date))
                                .font(.headline)
                            Text("\(section.foodEntries.count) foods • \(section.activities.count) activities")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .task {
            viewModel.load(context: modelContext)
        }
    }
}

#Preview {
    HistoryHomeView()
}