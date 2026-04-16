public protocol Repository<Model>: Sendable {
    associatedtype Model: Codable & Sendable & Identifiable

    func get(_ id: Model.ID) throws -> Model?
    func save(_ model: Model) throws
    func save(_ models: [Model]) throws
    func delete(_ model: Model) throws
    func delete(_ id: Model.ID) throws
    func exists(_ id: Model.ID) throws -> Bool
    func fetchAll() throws -> [Model]
    func deleteAll() throws
    func count() throws -> Int
    func transaction(_ block: @Sendable () throws -> Void) throws
}

extension Repository where Model.ID: CustomStringConvertible {
    public func delete(_ ids: [Model.ID]) throws {
        for id in ids {
            try delete(id)
        }
    }
}
