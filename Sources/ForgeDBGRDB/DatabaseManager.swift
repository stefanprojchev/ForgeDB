import Foundation
import GRDB

public final class DatabaseManager: Sendable {
    public let dbWriter: any DatabaseWriter

    public init(
        path: String,
        migrations: (inout DatabaseMigrator) -> Void
    ) throws {
        let directory = URL(filePath: path).deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let dbQueue = try DatabaseQueue(path: path)
        self.dbWriter = dbQueue
        var migrator = DatabaseMigrator()
        migrations(&migrator)
        try migrator.migrate(dbQueue)
    }

    public init(
        name: String,
        directory: URL,
        migrations: (inout DatabaseMigrator) -> Void
    ) throws {
        let path = directory.appending(path: "\(name).sqlite").path()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let dbQueue = try DatabaseQueue(path: path)
        self.dbWriter = dbQueue
        var migrator = DatabaseMigrator()
        migrations(&migrator)
        try migrator.migrate(dbQueue)
    }

    private init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public static func inMemory(
        migrations: (inout DatabaseMigrator) -> Void
    ) throws -> DatabaseManager {
        let dbQueue = try DatabaseQueue()
        var migrator = DatabaseMigrator()
        migrations(&migrator)
        try migrator.migrate(dbQueue)
        return DatabaseManager(dbWriter: dbQueue)
    }
}
