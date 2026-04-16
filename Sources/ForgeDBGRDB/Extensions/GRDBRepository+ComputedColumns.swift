import Foundation
import GRDB
import ForgeDB

extension GRDBRepository where Model: ComputedColumns {
    public func saveWithRecompute(_ model: Model) throws {
        var mutable = model
        mutable.recompute()
        try save(mutable)
    }

    public func saveWithRecompute(_ models: [Model]) throws {
        for model in models {
            try saveWithRecompute(model)
        }
    }
}
