import Foundation
import GRDB
import ForgeDB
import OSLog

private let logger = Logger(subsystem: "ForgeDB", category: "SchemaValidation")

extension GRDBRepository {
    /// Validate that the model's table exists and that model columns match the database schema.
    /// Logs warnings for missing or extra columns. Only runs in DEBUG builds.
    ///
    /// Model column names are extracted by fetching one row and reading which columns
    /// the model encodes via `databaseDictionary`. If the table is empty, only the
    /// DB columns are logged (no comparison is possible).
    public func validateSchema() throws {
        #if DEBUG
        try dbWriter.read { db in
            let tableName = Model.databaseTableName
            guard try db.tableExists(tableName) else {
                logger.error("Table '\(tableName)' does not exist")
                throw DBError.fetchFailed(underlying: "Table '\(tableName)' does not exist")
            }
            let dbColumns = try db.columns(in: tableName)
            let dbColumnNames = Set(dbColumns.map(\.name))

            if let record = try Model.fetchOne(db) {
                let modelColumnNames = Set(try record.databaseDictionary.keys)

                let missingInDB = modelColumnNames.subtracting(dbColumnNames)
                let extraInDB = dbColumnNames.subtracting(modelColumnNames)

                if missingInDB.isEmpty && extraInDB.isEmpty {
                    logger.info("Table '\(tableName)' schema matches model")
                } else {
                    if !missingInDB.isEmpty {
                        logger.warning("Table '\(tableName)' is missing columns expected by model: \(missingInDB.sorted().joined(separator: ", "))")
                    }
                    if !extraInDB.isEmpty {
                        logger.info("Table '\(tableName)' has extra columns not in model: \(extraInDB.sorted().joined(separator: ", "))")
                    }
                }
            } else {
                logger.info("Table '\(tableName)' is empty, skipping column comparison. DB columns: \(dbColumnNames.sorted().joined(separator: ", "))")
            }
        }
        #endif
    }
}
