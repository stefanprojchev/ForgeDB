import Foundation
import GRDB
import ForgeDB

/// Archivable support uses a flag-based approach (archivedAt column on the same table)
/// rather than a separate archive table. This is simpler and keeps queries straightforward
/// while still allowing archived records to be filtered or restored.
extension GRDBRepository where Model: Archivable {
    public func archive(_ model: Model) throws {
        var mutable = model
        mutable.archivedAt = .now
        try save(mutable)
    }

    /// Archive all records matching the given filter.
    public func archive(filter: any SQLSpecificExpressible) throws {
        let models = try fetch(filter: filter, sort: nil, limit: nil)
        try dbWriter.write { db in
            for model in models {
                var mutable = model
                mutable.archivedAt = .now
                try self._save(mutable, in: db)
            }
        }
    }

    public func unarchive(_ model: Model) throws {
        var mutable = model
        mutable.archivedAt = nil
        try save(mutable)
    }

    public func fetchActive() throws -> [Model] {
        try fetch(filter: GRDB.Column("archivedAt") == nil, sort: nil, limit: nil)
    }

    public func fetchArchived() throws -> [Model] {
        try fetch(filter: GRDB.Column("archivedAt") != nil, sort: nil, limit: nil)
    }
}
