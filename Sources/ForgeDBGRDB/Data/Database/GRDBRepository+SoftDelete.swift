import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: SoftDeletable {
    public func softDelete(_ model: Model) throws {
        var mutable = model
        mutable.isDeleted = true
        mutable.deletedAt = .now
        try save(mutable)
    }

    public func restore(_ model: Model) throws {
        var mutable = model
        mutable.isDeleted = false
        mutable.deletedAt = nil
        try save(mutable)
    }

    public func fetchActive() throws -> [Model] {
        try fetch(filter: GRDB.Column("isDeleted") == false, sort: nil, limit: nil)
    }

    public func fetchDeleted() throws -> [Model] {
        try fetch(filter: GRDB.Column("isDeleted") == true, sort: nil, limit: nil)
    }

    public func purge() throws {
        try delete(filter: GRDB.Column("isDeleted") == true)
    }
}
