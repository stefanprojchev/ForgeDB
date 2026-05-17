import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    /// Fetch models with a hasMany association (e.g., Author with Books).
    /// Fetches each model then queries its children using the association's foreign key.
    public func fetchWithChildren<Child: FetchableRecord & TableRecord>(
        _ association: HasManyAssociation<Model, Child>,
        filter: (any SQLSpecificExpressible)? = nil,
        sort: (any SQLOrderingTerm)? = nil
    ) throws -> [(model: Model, children: [Child])] {
        try dbWriter.read { db in
            var baseRequest = Model.all()
            if let filter { baseRequest = baseRequest.filter(filter) }
            if let sort { baseRequest = baseRequest.order(sort) }
            let models = try baseRequest.fetchAll(db)
            return try models.map { model in
                let children = try model.request(for: association).fetchAll(db)
                return (model: model, children: children)
            }
        }
    }

    /// Fetch models with a belongsTo association (e.g., Book with Author).
    /// Fetches each model then queries its parent using the association's foreign key.
    public func fetchWithParent<Parent: FetchableRecord & TableRecord>(
        _ association: BelongsToAssociation<Model, Parent>,
        filter: (any SQLSpecificExpressible)? = nil,
        sort: (any SQLOrderingTerm)? = nil
    ) throws -> [(model: Model, parent: Parent?)] {
        try dbWriter.read { db in
            var baseRequest = Model.all()
            if let filter { baseRequest = baseRequest.filter(filter) }
            if let sort { baseRequest = baseRequest.order(sort) }
            let models = try baseRequest.fetchAll(db)
            return try models.map { model in
                let parent = try model.request(for: association).fetchOne(db)
                return (model: model, parent: parent)
            }
        }
    }
}
