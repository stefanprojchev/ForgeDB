import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("DatabaseManager Extensions")
struct DatabaseManagerExtensionTests {

    @Test func stats() throws {
        let manager = try makeTestManager()
        let repo = GRDBRepository<TestRecord>(manager: manager)
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))

        let stats = try manager.stats()
        let testTable = stats.tables.first { $0.name == "testRecord" }
        #expect(testTable != nil)
        #expect(testTable?.rowCount == 2)
    }

    @Test func countsForTables() throws {
        let manager = try makeTestManager()
        let repo = GRDBRepository<TestRecord>(manager: manager)
        try repo.save(TestRecord(name: "A"))

        let counts = try manager.counts(for: ["testRecord"])
        #expect(counts["testRecord"] == 1)
    }

    @Test func vacuum() throws {
        let manager = try makeTestManager()
        // Just verify it doesn't throw
        try manager.vacuum()
    }

    @Test func reset() throws {
        let manager = try makeTestManager()
        let repo = GRDBRepository<TestRecord>(manager: manager)
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))
        #expect(try repo.count() == 2)

        try manager.reset { migrator in
            migrator.registerMigration("v1") { db in
                try db.create(table: "testRecord") { t in
                    t.primaryKey("id", .text)
                    t.column("name", .text).notNull()
                    t.column("score", .integer).notNull().defaults(to: 0)
                    t.column("isActive", .boolean).notNull().defaults(to: true)
                    t.column("createdAt", .datetime).notNull()
                    t.column("updatedAt", .datetime).notNull()
                }
            }
        }

        #expect(try repo.count() == 0)
        // Verify table still works after reset
        try repo.save(TestRecord(name: "New"))
        #expect(try repo.count() == 1)
    }
}
