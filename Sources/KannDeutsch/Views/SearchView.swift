import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: DictionaryViewModel
    @StateObject private var searchViewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search header
            VStack(spacing: 16) {
                // Title
                HStack {
                    Image(systemName: "book.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("KannDeutsch")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(viewModel.totalEntries.formatted()) entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Search bar
                SearchBar(text: $viewModel.searchConfiguration.searchText)
                    .padding(.horizontal)
                
                // Search options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Search mode
                        Menu {
                            ForEach(SearchMode.allCases) { mode in
                                Button(action: {
                                    viewModel.searchConfiguration.searchMode = mode
                                }) {
                                    Label(mode.rawValue, systemImage: mode.icon)
                                        .foregroundStyle(
                                            viewModel.searchConfiguration.searchMode == mode ? Theme.accentColor : .primary
                                        )
                                }
                            }
                        } label: {
                            ChipView(
                                title: viewModel.searchConfiguration.searchMode.rawValue,
                                icon: viewModel.searchConfiguration.searchMode.icon,
                                isActive: true
                            )
                        }
                        
                        // Sort mode
                        Menu {
                            ForEach(SortMode.allCases) { mode in
                                Button(action: {
                                    viewModel.searchConfiguration.sortMode = mode
                                }) {
                                    Text(mode.rawValue)
                                        .foregroundStyle(
                                            viewModel.searchConfiguration.sortMode == mode ? Theme.accentColor : .primary
                                        )
                                }
                            }
                        } label: {
                            ChipView(
                                title: "Sort: \(viewModel.searchConfiguration.sortMode.rawValue)",
                                icon: "arrow.up.arrow.down",
                                isActive: false
                            )
                        }
                        
                        // Idioms filter
                        Button(action: {
                            viewModel.searchConfiguration.showOnlyIdioms.toggle()
                        }) {
                            ChipView(
                                title: "Idioms",
                                icon: "quote.bubble",
                                isActive: viewModel.searchConfiguration.showOnlyIdioms
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .background(Theme.backgroundSecondary)
            
            Divider()
            
            // Content
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        viewModel.retry()
                    }
                } else {
                    EntryListView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            searchViewModel.loadRecentSearches()
        }
    }
}

struct ChipView: View {
    let title: String
    let icon: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            isActive ? Theme.accentColor : Theme.backgroundTertiary,
            in: Capsule()
        )
        .foregroundStyle(isActive ? .white : .primary)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Theme.accentColor)

            Text("Loading dictionary...")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Error")
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(Theme.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
