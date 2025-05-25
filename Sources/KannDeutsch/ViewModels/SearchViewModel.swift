import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var recentSearches: [String] = []
    @Published var suggestions: [String] = []
    
    private let maxRecentSearches = 10
    
    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0 == trimmed }
        
        // Add to beginning
        recentSearches.insert(trimmed, at: 0)
        
        // Keep only max number
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: "RecentSearches") {
            recentSearches = saved
        }
    }
}