import Foundation

@MainActor
class DictionaryRepository {
    private let database = DatabaseService()
    
    func initialize() async throws {
        try await database.initialize()
    }
    
    func getTotalCount() async throws -> Int {
        try await database.getTotalCount()
    }
    
    func getRandomEntries(count: Int) async throws -> [DictionaryEntry] {
        try await database.getRandomEntries(limit: count)
    }
    
    func search(query: String, mode: SearchMode) async throws -> [DictionaryEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        
        return try await database.search(
            query: trimmed,
            mode: mode,
            limit: 200
        )
    }
}