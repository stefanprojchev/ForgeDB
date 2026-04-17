import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    public func upsert(_ model: Model) throws {
        try dbWriter.write { db in
            try model.upsert(db)
        }
    }

    public func upsert(_ models: [Model]) throws {
        try dbWriter.write { db in
            for model in models {
                try model.upsert(db)
            }
        }
    }
}
