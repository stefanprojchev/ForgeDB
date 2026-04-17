import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: Timestampable {
    public func saveWithTimestamps(_ model: Model) throws {
        try dbWriter.write { db in
            var mutable = model
            let now = Date.now
            let isInsert = try !self._exists(model.id, in: db)
            if isInsert {
                mutable.createdAt = now
            }
            mutable.updatedAt = now
            try self._save(mutable, in: db)
        }
    }

    public func saveWithTimestamps(_ models: [Model]) throws {
        try dbWriter.write { db in
            let now = Date.now
            for model in models {
                var mutable = model
                let isInsert = try !self._exists(model.id, in: db)
                if isInsert {
                    mutable.createdAt = now
                }
                mutable.updatedAt = now
                try self._save(mutable, in: db)
            }
        }
    }
}
