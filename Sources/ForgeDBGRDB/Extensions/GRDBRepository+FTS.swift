import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    /// Search using an FTS5 virtual table that synchronizes with the model's table.
    /// The FTS table must be created in migrations with `synchronize(withTable:)`.
    ///
    /// Uses a raw SQL JOIN between the content table and the FTS virtual table --
    /// required when querying columns from the regular (non-FTS) content table.
    /// Results are ordered by FTS5 rank (best match first).
    /// Returns an empty array if the query produces no valid FTS5 pattern tokens.
    public func search(
        _ query: String,
        in ftsTable: String,
        limit: Int? = nil
    ) throws -> [Model] {
        try validateTableName(ftsTable)
        guard let pattern = FTS5Pattern(matchingAllPrefixesIn: query) else {
            return []
        }
        return try dbWriter.read { db in
            let tableName = Model.databaseTableName
            let quotedTable = "\"\(tableName)\""
            let quotedFTS = "\"\(ftsTable)\""
            var sql = """
                SELECT \(quotedTable).*
                FROM \(quotedTable)
                JOIN \(quotedFTS)
                    ON \(quotedFTS).rowid = \(quotedTable).rowid
                    AND \(quotedFTS) MATCH ?
                """
            if let limit {
                sql += " LIMIT \(limit)"
            }
            return try Model.fetchAll(db, sql: sql, arguments: [pattern])
        }
    }
}
