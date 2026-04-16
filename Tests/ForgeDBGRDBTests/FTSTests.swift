import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

struct FTSRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "ftsRecord"

    var id: Int64?
    var title: String
    var body: String

    enum Column: String, CodingKey, ColumnExpression {
        case id, title, body
    }

    init(title: String, body: String) {
        self.id = nil
        self.title = title
        self.body = body
    }
}

func makeFTSManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "ftsRecord") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("body", .text).notNull()
            }
            try db.create(virtualTable: "ftsRecord_ft", using: FTS5()) { t in
                t.synchronize(withTable: "ftsRecord")
                t.column("title")
                t.column("body")
            }
        }
    }
}

@Suite("FTS5 Search")
struct FTSTests {

    @Test func searchFindsMatches() throws {
        let repo = try GRDBRepository<FTSRecord>(manager: makeFTSManager())
        try repo.save(FTSRecord(title: "Swift Concurrency", body: "Learn about async await"))
        try repo.save(FTSRecord(title: "SwiftUI Views", body: "Building user interfaces"))
        try repo.save(FTSRecord(title: "Python Basics", body: "Getting started with Python"))

        let results = try repo.search("swift", in: "ftsRecord_ft")
        #expect(results.count == 2)
    }

    @Test func searchNoResults() throws {
        let repo = try GRDBRepository<FTSRecord>(manager: makeFTSManager())
        try repo.save(FTSRecord(title: "Swift", body: "iOS"))

        let results = try repo.search("python", in: "ftsRecord_ft")
        #expect(results.isEmpty)
    }

    @Test func searchWithLimit() throws {
        let repo = try GRDBRepository<FTSRecord>(manager: makeFTSManager())
        for i in 0..<10 {
            try repo.save(FTSRecord(title: "Swift Topic \(i)", body: "Content about Swift"))
        }

        let results = try repo.search("swift", in: "ftsRecord_ft", limit: 3)
        #expect(results.count == 3)
    }

    @Test func searchEmptyQueryReturnsEmpty() throws {
        let repo = try GRDBRepository<FTSRecord>(manager: makeFTSManager())
        try repo.save(FTSRecord(title: "Swift", body: "iOS"))

        let results = try repo.search("", in: "ftsRecord_ft")
        #expect(results.isEmpty)
    }
}
