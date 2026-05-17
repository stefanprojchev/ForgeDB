import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: ComputedColumns {
    public func saveWithRecompute(_ model: Model) throws {
        var mutable = model
        mutable.recompute()
        try dbWriter.write { db in
            try self._save(mutable, in: db)
        }
    }

    public func saveWithRecompute(_ models: [Model]) throws {
        try dbWriter.write { db in
            for model in models {
                var mutable = model
                mutable.recompute()
                try self._save(mutable, in: db)
            }
        }
    }
}
