import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    /// Search using an FTS5 virtual table that synchronizes with the model's table.
    /// The FTS table must be created in migrations with `synchronize(withTable:)`.
    ///
    /// Uses a raw SQL JOIN between the content table and the FTS virtual table —
    /// required when querying columns from the regular (non-FTS) content table.
    /// Returns an empty array if the query produces no valid FTS5 pattern tokens.
    public func search(
        _ query: String,
        in ftsTable: String,
        sort: (any SQLOrderingTerm)? = nil,
        limit: Int? = nil
    ) throws -> [Model] {
        guard let pattern = FTS5Pattern(matchingAllPrefixesIn: query) else {
            return []
        }
        return try dbWriter.read { db in
            let tableName = Model.databaseTableName
            var sql = """
                SELECT \(tableName).*
                FROM \(tableName)
                JOIN \(ftsTable)
                    ON \(ftsTable).rowid = \(tableName).rowid
                    AND \(ftsTable) MATCH ?
                """
            if let limit {
                sql += " LIMIT \(limit)"
            }
            return try Model.fetchAll(db, sql: sql, arguments: [pattern])
        }
    }
}
