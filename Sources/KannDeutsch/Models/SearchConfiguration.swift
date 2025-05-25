import Foundation

enum SearchMode: String, CaseIterable, Identifiable {
    case both = "Both"
    case german = "German"
    case english = "English"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .both: return "globe"
        case .german: return "flag"
        case .english: return "flag.fill"
        }
    }
}

enum SortMode: String, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case alphabetical = "A-Z"
    case reverseAlphabetical = "Z-A"
    
    var id: String { rawValue }
}

struct SearchConfiguration {
    var searchText: String = ""
    var searchMode: SearchMode = .both
    var sortMode: SortMode = .relevance
    var showOnlyIdioms: Bool = false
}