import Foundation
import GRDB
import ForgeDB

public struct Page<Model: Sendable>: Sendable {
    public let items: [Model]
    public let page: Int
    public let pageSize: Int
    public let totalCount: Int

    public var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return (totalCount + pageSize - 1) / pageSize
    }

    public var hasNextPage: Bool {
        page < totalPages
    }

    public var hasPreviousPage: Bool {
        page > 1
    }
}

extension GRDBRepository {
    public func fetch(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        page: Int,
        pageSize: Int
    ) throws -> Page<Model> {
        try dbWriter.read { db in
            var countRequest = Model.all()
            if let filter { countRequest = countRequest.filter(filter) }
            let totalCount = try countRequest.fetchCount(db)

            let offset = (page - 1) * pageSize
            var itemsRequest = Model.all()
            if let filter { itemsRequest = itemsRequest.filter(filter) }
            if let sort { itemsRequest = itemsRequest.order(sort) }
            itemsRequest = itemsRequest.limit(pageSize, offset: offset)
            let items = try itemsRequest.fetchAll(db)

            return Page(items: items, page: page, pageSize: pageSize, totalCount: totalCount)
        }
    }
}
