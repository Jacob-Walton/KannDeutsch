import Foundation

@MainActor
class SearchService {
    private var currentTask: Task<[DictionaryEntry], Error>?
    
    func search(
        query: String,
        mode: SearchMode,
        repository: DictionaryRepository
    ) async throws -> [DictionaryEntry] {
        // Cancel previous search
        currentTask?.cancel()
        
        // Create new search task
        let searchQuery = query
        let searchMode = mode
        
        let task = Task<[DictionaryEntry], Error> {
            try await repository.search(query: searchQuery, mode: searchMode)
        }
        
        currentTask = task
        
        do {
            let results = try await task.value
            return results
        } catch {
            if error is CancellationError {
                return []
            }
            throw error
        }
    }
    
    func cancelCurrentSearch() {
        currentTask?.cancel()
        currentTask = nil
    }
}