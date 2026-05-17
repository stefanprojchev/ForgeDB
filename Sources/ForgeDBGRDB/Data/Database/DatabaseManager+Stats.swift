import Foundation
import GRDB
import ForgeDB

extension DatabaseManager {
    public func stats() throws -> DBStats {
        try dbWriter.read { db in
            // Table names come from sqlite_master so they're trusted,
            // but we still quote them with double quotes for safety.
            let tables = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'grdb_%'
                """)

            var tableStats: [TableStats] = []
            for table in tables {
                let count = try Int.fetchOne(db, sql: "SELECT count(*) FROM \"\(table)\"") ?? 0
                tableStats.append(TableStats(name: table, rowCount: count))
            }

            var fileSize: UInt64 = 0
            if let dbQueue = dbWriter as? DatabaseQueue,
               let attrs = try? FileManager.default.attributesOfItem(atPath: dbQueue.path) {
                fileSize = attrs[.size] as? UInt64 ?? 0
            }

            return DBStats(fileSizeBytes: fileSize, tables: tableStats)
        }
    }

    public func vacuum() throws {
        try dbWriter.writeWithoutTransaction { db in
            try db.execute(sql: "VACUUM")
        }
    }

    public func counts(for tables: [String]) throws -> [String: Int] {
        for table in tables {
            try validateTableName(table)
        }
        return try dbWriter.read { db in
            var result: [String: Int] = [:]
            for table in tables {
                let count = try Int.fetchOne(db, sql: "SELECT count(*) FROM \"\(table)\"") ?? 0
                result[table] = count
            }
            return result
        }
    }
}
