import Foundation
import ForgeCore

public final class InMemoryRepository<Model: Codable & Sendable & Identifiable>: Repository, @unchecked Sendable
where Model.ID: Hashable & Sendable {

    // MARK: - Dependencies

    private let storage = LockedState<[Model.ID: Model]>([:])

    // MARK: - Init

    public init() {}

    public init(_ seed: [Model]) {
        var dict: [Model.ID: Model] = [:]
        for item in seed {
            dict[item.id] = item
        }
        storage.withLock { $0 = dict }
    }

    // MARK: - Implementation

    public func get(_ id: Model.ID) throws -> Model? {
        storage.withLock { $0[id] }
    }

    public func save(_ model: Model) throws {
        storage.withLock { $0[model.id] = model }
    }

    public func save(_ models: [Model]) throws {
        storage.withLock { state in
            for model in models {
                state[model.id] = model
            }
        }
    }

    public func delete(_ model: Model) throws {
        _ = storage.withLock { $0.removeValue(forKey: model.id) }
    }

    public func delete(_ id: Model.ID) throws {
        _ = storage.withLock { $0.removeValue(forKey: id) }
    }

    public func delete(_ ids: [Model.ID]) throws {
        storage.withLock { state in
            for id in ids {
                state.removeValue(forKey: id)
            }
        }
    }

    public func exists(_ id: Model.ID) throws -> Bool {
        storage.withLock { $0[id] != nil }
    }

    public func fetchAll() throws -> [Model] {
        storage.withLock { Array($0.values) }
    }

    public func deleteAll() throws {
        storage.withLock { $0.removeAll() }
    }

    public func count() throws -> Int {
        storage.withLock { $0.count }
    }

    /// Executes the block and rolls back all changes if it throws.
    ///
    /// **Isolation caveat:** the snapshot-and-restore approach provides rollback-on-error
    /// but does NOT provide isolation from concurrent threads. Another thread can observe
    /// intermediate writes made inside the block before a rollback occurs. If you need
    /// true isolation, use a serial actor or a GRDB-backed repository.
    public func transaction(_ block: @Sendable () throws -> Void) throws {
        let snapshot = storage.withLock { $0 }
        do {
            try block()
        } catch {
            storage.withLock { $0 = snapshot }
            throw error
        }
    }
}
