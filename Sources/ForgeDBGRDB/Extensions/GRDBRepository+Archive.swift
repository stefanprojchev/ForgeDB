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

    public func archive(filter: any SQLSpecificExpressible) throws {
        _ = try dbWriter.write { db in
            try Model.filter(filter).updateAll(db, [Column("archivedAt").set(to: Date.now)])
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
