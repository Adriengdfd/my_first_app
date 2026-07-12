import SwiftUI
import SwiftData

struct SportProfileListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SportProfileListViewModel()
    @State private var draft = SportProfileDraft()
    @State private var editingProfile: SportProfile?
    @State private var isPresentingEditor = false

    var body: some View {
        List {
            if !viewModel.errorMessage.isEmpty {
                InlineMessageView(message: viewModel.errorMessage)
            }

            if viewModel.profiles.isEmpty {
                EmptyStateView(
                    title: "No sports yet",
                    message: "Create a sport profile with custom statistics.",
                    systemImage: "figure.mixed.cardio"
                )
            } else {
                ForEach(viewModel.profiles) { profile in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.sportName)
                            .font(.headline)
                        Text("Version \(profile.version) • \(profile.statisticDefinitions.count) statistics")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button("Edit") {
                            editingProfile = profile
                            draft = viewModel.makeDraft(from: profile)
                            isPresentingEditor = true
                        }
                    }
                }
            }
        }
        .navigationTitle("Sports")
        .toolbar {
            Button {
                editingProfile = nil
                draft = SportProfileDraft()
                isPresentingEditor = true
            } label: {
                Label("Add Sport", systemImage: "plus")
            }
        }
        .task {
            viewModel.load(context: modelContext)
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                SportProfileEditorView(draft: $draft) {
                    viewModel.save(draft: draft, editing: editingProfile, context: modelContext)
                    if viewModel.errorMessage.isEmpty {
                        isPresentingEditor = false
                    }
                }
            }
        }
    }
}

#Preview {
    SportProfileListView()
}