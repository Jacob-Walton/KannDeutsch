import Foundation
import SQLite

actor DatabaseService {
    private var db: Connection?
    private let entries = Table("dictionary_entries")
    
    // Columns
    private let id = Expression<Int>("id")
    private let germanBase = Expression<String>("german_base")
    private let englishBase = Expression<String>("english_base")
    private let germanGender = Expression<String?>("german_gender")
    private let germanAnnotations = Expression<String?>("german_annotations")
    private let germanVariations = Expression<String?>("german_variations")
    private let englishAnnotations = Expression<String?>("english_annotations")
    private let englishVariations = Expression<String?>("english_variations")
    private let partOfSpeech = Expression<String?>("part_of_speech")
    private let subjectDomain = Expression<String?>("subject_domain")
    private let usageLevel = Expression<String?>("usage_level")
    private let isIdiom = Expression<Bool>("is_idiom")
    
    func initialize() throws {
        guard let dbPath = Bundle.module.path(forResource: "output", ofType: "db") else {
            throw DatabaseError.fileNotFound
        }
        
        db = try Connection(dbPath, readonly: true)
        
        // Verify database
        let count = try db?.scalar(entries.count) ?? 0
        if count == 0 {
            throw DatabaseError.emptyDatabase
        }
    }
    
    func getTotalCount() throws -> Int {
        guard let db = db else { throw DatabaseError.notInitialized }
        return try db.scalar(entries.count)
    }
    
    func getRandomEntries(limit: Int) throws -> [DictionaryEntry] {
        guard let db = db else { throw DatabaseError.notInitialized }
        
        let query = entries
            .order(Expression<Int>.random())
            .limit(limit)
        
        return try db.prepare(query).map { row in
            mapRowToEntry(row)
        }
    }
    
    func search(query: String, mode: SearchMode, limit: Int) throws -> [DictionaryEntry] {
        guard let db = db else { throw DatabaseError.notInitialized }
        
        let searchTerm = query.lowercased()
        var dbQuery = entries.limit(limit)
        
        switch mode {
        case .german:
            dbQuery = dbQuery.filter(
                germanBase.lowercaseString.like("%\(searchTerm)%")
            )
        case .english:
            dbQuery = dbQuery.filter(
                englishBase.lowercaseString.like("%\(searchTerm)%")
            )
        case .both:
            dbQuery = dbQuery.filter(
                germanBase.lowercaseString.like("%\(searchTerm)%") ||
                englishBase.lowercaseString.like("%\(searchTerm)%")
            )
        }
        
        return try db.prepare(dbQuery).map { row in
            mapRowToEntry(row)
        }
    }
    
    private func mapRowToEntry(_ row: Row) -> DictionaryEntry {
        return DictionaryEntry(
            id: row[id],
            german: row[germanBase],
            english: row[englishBase],
            germanGender: row[germanGender],
            germanAnnotations: parseJSONArray(row[germanAnnotations]) ?? [],
            germanVariations: parseJSONArray(row[germanVariations]) ?? [],
            englishAnnotations: parseJSONArray(row[englishAnnotations]) ?? [],
            englishVariations: parseJSONArray(row[englishVariations]) ?? [],
            partOfSpeech: row[partOfSpeech],
            subjectDomain: row[subjectDomain],
            usageLevel: row[usageLevel],
            isIdiom: row[isIdiom]
        )
    }
    
    private func parseJSONArray(_ jsonString: String?) -> [String]? {
        guard let jsonString = jsonString,
              !jsonString.isEmpty,
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        return try? JSONDecoder().decode([String].self, from: data)
    }
}

enum DatabaseError: LocalizedError {
    case fileNotFound
    case notInitialized
    case emptyDatabase
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Dictionary database not found"
        case .notInitialized:
            return "Database not initialized"
        case .emptyDatabase:
            return "Database is empty"
        }
    }
}