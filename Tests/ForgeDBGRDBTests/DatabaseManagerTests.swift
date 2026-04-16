import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("DatabaseManager")
struct DatabaseManagerTests {

    @Test func inMemoryCreation() throws {
        let manager = try makeTestManager()
        #expect(manager.dbWriter is DatabaseQueue)
    }

    @Test func migrationsRun() throws {
        let manager = try makeTestManager()
        let tableExists = try manager.dbWriter.read { db in
            try db.tableExists("testRecord")
        }
        #expect(tableExists)
    }
}
