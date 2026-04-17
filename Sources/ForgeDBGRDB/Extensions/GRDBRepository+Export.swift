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
        try importJSON(data, strategy: strategy, batchSize: .max) { _ in }
    }
}
