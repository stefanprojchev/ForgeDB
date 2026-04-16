import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: Archivable {
    public func archive(_ model: Model) throws {
        var mutable = model
        mutable.archivedAt = .now
        try save(mutable)
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
