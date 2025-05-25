import Foundation

struct DictionaryEntry: Identifiable, Codable, Hashable {
    let id: Int
    let german: String
    let english: String
    let germanGender: String?
    let germanAnnotations: [String]
    let germanVariations: [String]
    let englishAnnotations: [String]
    let englishVariations: [String]
    let partOfSpeech: String?
    let subjectDomain: String?
    let usageLevel: String?
    let isIdiom: Bool
    
    var displayGerman: String {
        if let gender = germanGender, !gender.isEmpty {
            return "\(genderArticle) \(german)"
        }
        return german
    }
    
    var genderArticle: String {
        switch germanGender?.lowercased() {
        case "m": return "der"
        case "f": return "die"
        case "n": return "das"
        case "pl": return "die"
        default: return ""
        }
    }
    
    var genderInfo: (article: String, color: String, name: String) {
        switch germanGender?.lowercased() {
        case "m": return ("der", "masculine", "Masculine")
        case "f": return ("die", "feminine", "Feminine")
        case "n": return ("das", "neuter", "Neuter")
        case "pl": return ("die", "plural", "Plural")
        default: return ("", "none", "")
        }
    }
    
    var tags: [String] {
        var allTags: [String] = []
        
        if let domain = subjectDomain, !domain.isEmpty {
            allTags.append(contentsOf: domain.split(separator: ",").map { 
                $0.trimmingCharacters(in: .whitespaces) 
            })
        }
        
        if let usage = usageLevel, !usage.isEmpty {
            allTags.append(contentsOf: usage.split(separator: ",").map { 
                $0.trimmingCharacters(in: .whitespaces) 
            })
        }
        
        return allTags
    }
    
    var hasAdditionalInfo: Bool {
        !germanAnnotations.isEmpty || 
        !germanVariations.isEmpty || 
        !englishAnnotations.isEmpty || 
        !englishVariations.isEmpty ||
        partOfSpeech != nil ||
        !tags.isEmpty
    }
    
    func matches(_ searchText: String, mode: SearchMode) -> Bool {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return false }
        
        switch mode {
        case .german:
            return german.lowercased().contains(query) ||
                   germanVariations.contains { $0.lowercased().contains(query) }
        case .english:
            return english.lowercased().contains(query) ||
                   englishVariations.contains { $0.lowercased().contains(query) }
        case .both:
            return matches(query, mode: .german) || matches(query, mode: .english)
        }
    }
}