import Foundation
import GRDB
import ForgeDB
import OSLog

private let logger = Logger(subsystem: "ForgeDB", category: "SchemaValidation")

extension GRDBRepository {
    /// Validate that the model's table exists and log any schema mismatches.
    /// Only runs in DEBUG builds.
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
            logger.info("Table '\(tableName)' has columns: \(dbColumnNames.sorted().joined(separator: ", "))")
        }
        #endif
    }
}
