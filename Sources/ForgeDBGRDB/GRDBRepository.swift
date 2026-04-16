import Foundation
import GRDB
import ForgeDB

public final class GRDBRepository<Model>: @unchecked Sendable
where Model: Codable & Sendable & Identifiable & FetchableRecord & PersistableRecord,
      Model.ID: DatabaseValueConvertible & Sendable
{
    let dbWriter: any DatabaseWriter

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    public init(manager: DatabaseManager) {
        self.dbWriter = manager.dbWriter
    }
}

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

    public func transaction(_ block: @Sendable () throws -> Void) throws {
        try dbWriter.unsafeReentrantWrite { db in
            try db.inSavepoint {
                try block()
                return .commit
            }
        }
    }
}
