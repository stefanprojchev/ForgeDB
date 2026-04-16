import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    public func exportJSON(
        filter: (any SQLSpecificExpressible)? = nil,
        sort: (any SQLOrderingTerm)? = nil
    ) throws -> Data {
        let models = try fetch(filter: filter, sort: sort, limit: nil)
        return try JSONEncoder().encode(models)
    }

    public func importJSON(_ data: Data, strategy: ImportStrategy) throws {
        let models = try JSONDecoder().decode([Model].self, from: data)
        try dbWriter.unsafeReentrantWrite { db in
            switch strategy {
            case .insert:
                for model in models {
                    try model.insert(db)
                }
            case .upsert:
                for model in models {
                    try model.upsert(db)
                }
            case .replace:
                _ = try Model.deleteAll(db)
                for model in models {
                    try model.insert(db)
                }
            }
        }
    }
}
