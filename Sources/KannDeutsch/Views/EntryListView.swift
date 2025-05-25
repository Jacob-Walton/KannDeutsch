import SwiftUI

struct EntryListView: View {
    @EnvironmentObject var viewModel: DictionaryViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.searchConfiguration.searchText.isEmpty {
                    // Discovery mode
                    DiscoveryHeader()
                }
                
                if viewModel.filteredEntries.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "Try adjusting your search or filters"
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(viewModel.filteredEntries) { entry in
                        if sizeClass == .compact {
                            NavigationLink(destination: EntryDetailView(entry: entry)) {
                                EntryRow(entry: entry, searchText: viewModel.searchConfiguration.searchText)
                            }
                            .buttonStyle(.plain)
                        } else {
                            EntryRow(entry: entry, searchText: viewModel.searchConfiguration.searchText)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectEntry(entry)
                                }
                                .background(
                                    viewModel.selectedEntry?.id == entry.id ? 
                                    Theme.accentColor.opacity(0.1) : Color.clear
                                )
                        }
                        
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct DiscoveryHeader: View {
    @EnvironmentObject var viewModel: DictionaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Discover")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.loadRandomEntries()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.callout)
                        .foregroundStyle(Theme.accentColor)
                }
            }
            
            Text("Random entries to explore")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}