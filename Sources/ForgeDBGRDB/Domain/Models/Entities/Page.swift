import Foundation

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
