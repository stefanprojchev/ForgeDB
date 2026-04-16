import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    public func sum<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            return try request.select(GRDB.sum(column), as: V.self).fetchOne(db)
        }
    }

    public func average(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> Double? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            return try request.select(GRDB.average(column), as: Double.self).fetchOne(db)
        }
    }

    public func min<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            return try request.select(GRDB.min(column), as: V.self).fetchOne(db)
        }
    }

    public func max<V: DatabaseValueConvertible>(
        _ column: any ColumnExpression,
        filter: (any SQLSpecificExpressible)? = nil
    ) throws -> V? {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            return try request.select(GRDB.max(column), as: V.self).fetchOne(db)
        }
    }
}
