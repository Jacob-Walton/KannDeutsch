import SwiftUI
import Combine

@MainActor
class DictionaryViewModel: ObservableObject {
    @Published var entries: [DictionaryEntry] = []
    @Published var filteredEntries: [DictionaryEntry] = []
    @Published var selectedEntry: DictionaryEntry?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var searchConfiguration = SearchConfiguration()
    @Published var totalEntries = 0
    
    private let repository: DictionaryRepository
    private let searchService: SearchService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.repository = DictionaryRepository()
        self.searchService = SearchService()
        setupSearchSubscription()
    }
    
    func initialize() {
        Task {
            await loadDatabase()
        }
    }
    
    private func setupSearchSubscription() {
        $searchConfiguration
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] config in
                self?.performSearch(with: config)
            }
            .store(in: &cancellables)
    }
    
    private func loadDatabase() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.initialize()
            totalEntries = try await repository.getTotalCount()
            await loadRandomEntries()
            isLoading = false
        } catch {
            errorMessage = "Failed to load dictionary: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func loadRandomEntries() async {
        do {
            let randomEntries = try await repository.getRandomEntries(count: 50)
            entries = randomEntries
            filteredEntries = randomEntries
        } catch {
            print("Error loading random entries: \(error)")
        }
    }
    
    private func performSearch(with config: SearchConfiguration) {
        if config.searchText.isEmpty {
            filteredEntries = entries
            return
        }
        
        Task {
            do {
                let results = try await searchService.search(
                    query: config.searchText,
                    mode: config.searchMode,
                    repository: repository
                )
                
                var filtered = results
                
                // Apply idiom filter
                if config.showOnlyIdioms {
                    filtered = filtered.filter { $0.isIdiom }
                }
                
                // Apply sorting
                switch config.sortMode {
                case .relevance:
                    // Already sorted by relevance from search
                    break
                case .alphabetical:
                    filtered.sort { $0.german < $1.german }
                case .reverseAlphabetical:
                    filtered.sort { $0.german > $1.german }
                }
                
                filteredEntries = filtered
            } catch {
                print("Search error: \(error)")
            }
        }
    }
    
    func selectEntry(_ entry: DictionaryEntry) {
        selectedEntry = entry
    }
    
    func clearSearch() {
        searchConfiguration.searchText = ""
        selectedEntry = nil
    }
    
    func retry() {
        Task {
            await loadDatabase()
        }
    }
}