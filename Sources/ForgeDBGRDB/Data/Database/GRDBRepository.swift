import Foundation
import GRDB
import ForgeDB

public final class GRDBRepository<Model>: @unchecked Sendable
where Model: Codable & Sendable & Identifiable & FetchableRecord & PersistableRecord,
      Model.ID: DatabaseValueConvertible & Sendable
{

    // MARK: - Dependencies

    let dbWriter: any DatabaseWriter

    // MARK: - Init

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public init(manager: DatabaseManager) {
        self.dbWriter = manager.dbWriter
    }
}

// Internal db-accepting methods for composition within a single transaction.
extension GRDBRepository {
    func _save(_ model: Model, in db: Database) throws {
        try model.save(db)
    }

    func _delete(_ model: Model, in db: Database) throws {
        _ = try model.delete(db)
    }

    func _deleteByID(_ id: Model.ID, in db: Database) throws {
        _ = try Model.deleteOne(db, key: id)
    }

    func _exists(_ id: Model.ID, in db: Database) throws -> Bool {
        try Model.exists(db, key: id)
    }

    func _deleteAll(in db: Database) throws {
        _ = try Model.deleteAll(db)
    }
}

extension GRDBRepository: QueryableRepository {
    public func fetch(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        limit: Int?
    ) throws -> [Model] {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            if let sort { request = request.order(sort) }
            if let limit { request = request.limit(limit) }
            return try request.fetchAll(db)
        }
    }

    public func first(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?
    ) throws -> Model? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            if let sort { request = request.order(sort) }
            return try request.fetchOne(db)
        }
    }

    public func count(
        filter: (any SQLSpecificExpressible)?
    ) throws -> Int {
        try dbWriter.read { db in
            if let filter {
                return try Model.filter(filter).fetchCount(db)
            }
            return try Model.fetchCount(db)
        }
    }

    public func delete(
        filter: (any SQLSpecificExpressible)?
    ) throws {
        try dbWriter.write { db in
            if let filter {
                _ = try Model.filter(filter).deleteAll(db)
            } else {
                _ = try Model.deleteAll(db)
            }
        }
    }

    public func stream(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?
    ) -> AsyncStream<[Model]> {
        // SQLSpecificExpressible and SQLOrderingTerm are not Sendable, but they are
        // value-semantic SQL expressions consumed synchronously on GRDB's serial queue.
        // nonisolated(unsafe) is safe here because the values are read-only and only
        // accessed within ValueObservation.tracking which runs on GRDB's serial queue.
        nonisolated(unsafe) let capturedFilter = filter
        nonisolated(unsafe) let capturedSort = sort

        let observation = ValueObservation.tracking { db in
            var request = Model.all()
            if let filter = capturedFilter { request = request.filter(filter) }
            if let sort = capturedSort { request = request.order(sort) }
            return try request.fetchAll(db)
        }

        // Use the async sequence API to avoid the @MainActor start(in:onError:onChange:) overload.
        let values = observation.values(in: dbWriter)
        return AsyncStream { continuation in
            let task = Task {
                do {
                    for try await value in values {
                        continuation.yield(value)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func streamAll() -> AsyncStream<[Model]> {
        stream(filter: nil, sort: nil)
    }

    public func enumerate(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        batchSize: Int,
        body: @Sendable (Model) throws -> Void
    ) throws {
        try enumerate(filter: filter, sort: sort, batchSize: batchSize, progress: { _ in }, body: body)
    }
}

// Public save/delete/deleteAll methods use unsafeReentrantWrite so they can be
// called from within transaction() blocks, which already hold a write lock.
// Extensions that compose multiple operations should use dbWriter.write with
// the internal _save/_delete/_exists helpers instead.
extension GRDBRepository: Repository {
    public func get(_ id: Model.ID) throws -> Model? {
        try dbWriter.read { db in
            try Model.fetchOne(db, key: id)
        }
    }

    public func save(_ model: Model) throws {
        try dbWriter.unsafeReentrantWrite { db in
            try model.save(db)
        }
    }

    public func save(_ models: [Model]) throws {
        try dbWriter.unsafeReentrantWrite { db in
            for model in models {
                try model.save(db)
            }
        }
    }

    public func delete(_ model: Model) throws {
        try dbWriter.unsafeReentrantWrite { db in
            _ = try model.delete(db)
        }
    }

    public func delete(_ id: Model.ID) throws {
        try dbWriter.unsafeReentrantWrite { db in
            _ = try Model.deleteOne(db, key: id)
        }
    }

    /// Deletes all records with the given IDs in a single write transaction,
    /// avoiding the N+1 round-trips of calling `delete(_ id:)` in a loop.
    public func delete(_ ids: [Model.ID]) throws {
        try dbWriter.write { db in
            for id in ids {
                _ = try Model.deleteOne(db, key: id)
            }
        }
    }

    public func exists(_ id: Model.ID) throws -> Bool {
        try dbWriter.read { db in
            try Model.exists(db, key: id)
        }
    }

    public func fetchAll() throws -> [Model] {
        try dbWriter.read { db in
            try Model.fetchAll(db)
        }
    }

    public func deleteAll() throws {
        try dbWriter.unsafeReentrantWrite { db in
            _ = try Model.deleteAll(db)
        }
    }

    public func count() throws -> Int {
        try dbWriter.read { db in
            try Model.fetchCount(db)
        }
    }

    /// Execute a block inside a savepoint. The block can call public mutating
    /// methods (save, delete, deleteAll) which use `unsafeReentrantWrite` to
    /// allow reentrancy from within this write context.
    public func transaction(_ block: @Sendable () throws -> Void) throws {
        try dbWriter.unsafeReentrantWrite { db in
            try db.inSavepoint {
                try block()
                return .commit
            }
        }
    }
}
