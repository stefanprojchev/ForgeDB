import Foundation
import GRDB

extension DatabaseManager {
    /// Drops all user tables and re-runs migrations.
    /// Use for logout/account switching scenarios.
    public func reset(migrations: (inout DatabaseMigrator) -> Void) throws {
        try dbWriter.write { db in
            // Table names come from sqlite_master so they're trusted,
            // but we still quote them with double quotes for safety.
            let tables = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'
                """)
            for table in tables {
                try db.execute(sql: "DROP TABLE IF EXISTS \"\(table)\"")
            }
        }
        var migrator = DatabaseMigrator()
        migrations(&migrator)
        try migrator.migrate(dbWriter)
    }
}
