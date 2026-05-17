import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: Expirable {
    public func deleteExpired() throws {
        try delete(filter: GRDB.Column("expiresAt") < Date.now)
    }

    public func fetchValid() throws -> [Model] {
        try fetch(filter: GRDB.Column("expiresAt") >= Date.now, sort: nil, limit: nil)
    }
}
