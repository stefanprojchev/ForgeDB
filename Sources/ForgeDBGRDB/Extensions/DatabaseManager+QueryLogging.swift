import Foundation
import GRDB
import OSLog

private let logger = Logger(subsystem: "ForgeDB", category: "SQL")

extension DatabaseManager {
    /// Enable SQL query logging in DEBUG builds.
    /// Logs all queries via OSLog and highlights slow queries exceeding the threshold.
    public func enableQueryLogging(slowQueryThreshold: TimeInterval = 0.1) {
        #if DEBUG
        dbWriter.writeWithoutTransaction { db in
            db.trace(options: [.statement, .profile]) { event in
                switch event {
                case .statement(let statement):
                    logger.debug("SQL: \(statement.sql)")
                case .profile(let statement, let duration):
                    if duration > slowQueryThreshold {
                        logger.warning("SLOW QUERY (\(duration, format: .fixed(precision: 3))s): \(statement.sql)")
                    } else {
                        logger.debug("SQL (\(duration, format: .fixed(precision: 3))s): \(statement.sql)")
                    }
                }
            }
        }
        #endif
    }
}
