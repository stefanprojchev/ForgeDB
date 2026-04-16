import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

struct TestRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "testRecord"

    var id: UUID
    var name: String
    var score: Int
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    enum Column: String, CodingKey, ColumnExpression {
        case id, name, score, isActive, createdAt, updatedAt
    }

    init(id: UUID = UUID(), name: String, score: Int = 0, isActive: Bool = true, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.score = score
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

func makeTestManager() throws -> DatabaseManager {
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
        }
    }
}
