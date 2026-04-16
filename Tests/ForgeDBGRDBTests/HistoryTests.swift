import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

func makeHistoryManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "testRecord") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("score", .integer).notNull().defaults(to: 0)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
            try db.create(table: "testRecord_history") { t in
                t.primaryKey("id", .text)
                t.column("modelId", .text).notNull()
                t.column("snapshot", .text).notNull()
                t.column("changedAt", .datetime).notNull()
                t.column("action", .text).notNull()
            }
        }
    }
}

@Suite("History")
struct HistoryTests {

    @Test func saveWithHistoryRecordsInsert() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeHistoryManager())
        let record = TestRecord(name: "Test")
        try repo.saveWithHistory(record)

        let entries = try repo.history(for: record.id)
        #expect(entries.count == 1)
        #expect(entries[0].action == .insert)
        #expect(entries[0].snapshot.name == "Test")
    }

    @Test func saveWithHistoryRecordsUpdate() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeHistoryManager())
        let record = TestRecord(name: "Original")
        try repo.saveWithHistory(record)

        var updated = record
        updated.name = "Updated"
        try repo.saveWithHistory(updated)

        let entries = try repo.history(for: record.id)
        #expect(entries.count == 2)
        #expect(entries[0].action == .update) // newest first
        #expect(entries[1].action == .insert)
    }

    @Test func historyWithLimit() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeHistoryManager())
        let record = TestRecord(name: "V1")
        try repo.saveWithHistory(record)
        var v2 = record; v2.name = "V2"
        try repo.saveWithHistory(v2)
        var v3 = record; v3.name = "V3"
        try repo.saveWithHistory(v3)

        let entries = try repo.history(for: record.id, limit: 2)
        #expect(entries.count == 2)
    }
}
