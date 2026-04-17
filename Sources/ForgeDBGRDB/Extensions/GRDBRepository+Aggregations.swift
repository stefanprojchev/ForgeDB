import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    private func _aggregate<V: DatabaseValueConvertible>(
        _ aggregate: any SQLSpecificExpressible,
        filter: (any SQLSpecificExpressible)?
    ) throws -> V? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            return try request.select(aggregate, as: V.self).fetchOne(db)
        }
    }

    public func sum<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try _aggregate(GRDB.sum(column), filter: filter)
    }

    public func average(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> Double? {
        try _aggregate(GRDB.average(column), filter: filter) as Double?
    }

    public func min<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try _aggregate(GRDB.min(column), filter: filter)
    }

    public func max<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try _aggregate(GRDB.max(column), filter: filter)
    }
}
