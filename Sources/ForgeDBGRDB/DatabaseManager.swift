import Foundation
import GRDB

public final class DatabaseManager: Sendable {
    public let dbWriter: any DatabaseWriter

    public init(
        path: String,
        migrations: (inout DatabaseMigrator) -> Void
    ) throws {
        self.dbWriter = try DatabaseManager.createAndMigrate(path: path, migrations: migrations)
    }

    public init(
        name: String,
        directory: URL,
        migrations: (inout DatabaseMigrator) -> Void
    ) throws {
        let path = directory.appending(path: "\(name).sqlite").path()
        self.dbWriter = try DatabaseManager.createAndMigrate(path: path, migrations: migrations)
    }

    private init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    private static func createAndMigrate(
        path: String,
        migrations: (inout DatabaseMigrator) -> Void
    ) throws -> any DatabaseWriter {
        let directory = URL(filePath: path).deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let dbQueue = try DatabaseQueue(path: path)
        var migrator = DatabaseMigrator()
        migrations(&migrator)
        try migrator.migrate(dbQueue)
        return dbQueue
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
