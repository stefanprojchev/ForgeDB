import Foundation
import GRDB
import ForgeDB

public protocol QueryableRepository<Model>: Repository {
    func fetch(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        limit: Int?
    ) throws -> [Model]

    func first(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?
    ) throws -> Model?

    func count(
        filter: (any SQLSpecificExpressible)?
    ) throws -> Int

    func delete(
        filter: (any SQLSpecificExpressible)?
    ) throws

    func stream(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?
    ) -> AsyncStream<[Model]>

    func streamAll() -> AsyncStream<[Model]>

    func enumerate(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        batchSize: Int,
        body: @Sendable (Model) throws -> Void
    ) throws
}
