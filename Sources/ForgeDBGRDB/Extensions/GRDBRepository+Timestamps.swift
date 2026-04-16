import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: Timestampable {
    public func saveWithTimestamps(_ model: Model) throws {
        var mutable = model
        let now = Date.now
        let isInsert = try !exists(model.id)
        if isInsert {
            mutable.createdAt = now
        }
        mutable.updatedAt = now
        try save(mutable)
    }

    public func saveWithTimestamps(_ models: [Model]) throws {
        for model in models {
            try saveWithTimestamps(model)
        }
    }
}
