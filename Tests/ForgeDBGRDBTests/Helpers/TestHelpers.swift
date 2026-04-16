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

// MARK: - TimestampRecord

struct TimestampRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord, Timestampable {
    static let databaseTableName = "timestampRecord"

    var id: UUID
    var name: String
    var createdAt: Date = .distantPast
    var updatedAt: Date = .distantPast

    enum Column: String, CodingKey, ColumnExpression {
        case id, name, createdAt, updatedAt
    }

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

func makeTimestampManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "timestampRecord") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
        }
    }
}

// MARK: - SoftDeleteRecord

struct SoftDeleteRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord, SoftDeletable {
    static let databaseTableName = "softDeleteRecord"

    var id: UUID
    var name: String
    var isDeleted: Bool = false
    var deletedAt: Date? = nil

    enum Column: String, CodingKey, ColumnExpression {
        case id, name, isDeleted, deletedAt
    }

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

func makeSoftDeleteManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "softDeleteRecord") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("isDeleted", .boolean).notNull().defaults(to: false)
                t.column("deletedAt", .datetime)
            }
        }
    }
}

// MARK: - ExpirableRecord

struct ExpirableRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord, Expirable {
    static let databaseTableName = "expirableRecord"

    var id: UUID
    var name: String
    var expiresAt: Date

    enum Column: String, CodingKey, ColumnExpression {
        case id, name, expiresAt
    }

    init(id: UUID = UUID(), name: String, expiresAt: Date) {
        self.id = id
        self.name = name
        self.expiresAt = expiresAt
    }
}

func makeExpirableManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "expirableRecord") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("expiresAt", .datetime).notNull()
            }
        }
    }
}

// MARK: - ArchivableRecord

struct ArchivableRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord, Archivable {
    static let databaseTableName = "archivableRecord"

    var id: UUID
    var name: String
    var archivedAt: Date? = nil

    enum Column: String, CodingKey, ColumnExpression {
        case id, name, archivedAt
    }

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

func makeArchivableManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "archivableRecord") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("archivedAt", .datetime)
            }
        }
    }
}

// MARK: - ComputedRecord

struct ComputedRecord: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord, ComputedColumns {
    static let databaseTableName = "computedRecord"

    var id: UUID
    var firstName: String
    var lastName: String
    var fullName: String = ""
    var searchableText: String = ""

    enum Column: String, CodingKey, ColumnExpression {
        case id, firstName, lastName, fullName, searchableText
    }

    init(id: UUID = UUID(), firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }

    mutating func recompute() {
        fullName = "\(firstName) \(lastName)"
        searchableText = "\(firstName) \(lastName)".lowercased()
    }
}

func makeComputedManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "computedRecord") { t in
                t.primaryKey("id", .text)
                t.column("firstName", .text).notNull()
                t.column("lastName", .text).notNull()
                t.column("fullName", .text).notNull().defaults(to: "")
                t.column("searchableText", .text).notNull().defaults(to: "")
            }
        }
    }
}
