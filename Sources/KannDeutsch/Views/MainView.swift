import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: DictionaryViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone layout
                NavigationStack {
                    SearchView()
                }
            } else {
                // iPad/Mac layout
                NavigationSplitView {
                    SearchView()
                        .navigationSplitViewColumnWidth(min: 320, ideal: 400, max: 500)
                } detail: {
                    if let entry = viewModel.selectedEntry {
                        EntryDetailView(entry: entry)
                    } else {
                        EmptyStateView(
                            icon: "book.fill",
                            title: "Select an Entry",
                            message: "Choose a word from the list to see its details"
                        )
                    }
                }
                .navigationSplitViewStyle(.balanced)
            }
        }
        .tint(Theme.accentColor)
    }
}