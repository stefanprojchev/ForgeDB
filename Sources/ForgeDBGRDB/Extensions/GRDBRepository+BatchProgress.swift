import Foundation
import GRDB
import ForgeDB

public struct ImportProgress: Sendable {
    public let processed: Int
    public let total: Int
}

public struct EnumerateProgress: Sendable {
    public let processed: Int
}

extension GRDBRepository {
    public func importJSON(
        _ data: Data,
        strategy: ImportStrategy,
        batchSize: Int = 500,
        progress: @Sendable (ImportProgress) -> Void
    ) throws {
        let models = try JSONDecoder().decode([Model].self, from: data)
        let total = models.count
        try dbWriter.write { db in
            if strategy == .replace {
                _ = try Model.deleteAll(db)
            }
            for (index, model) in models.enumerated() {
                switch strategy {
                case .insert, .replace:
                    try model.insert(db)
                case .upsert:
                    try model.upsert(db)
                }
                if (index + 1) % batchSize == 0 || index == total - 1 {
                    progress(ImportProgress(processed: index + 1, total: total))
                }
            }
        }
    }

    public func enumerate(
        filter: (any SQLSpecificExpressible)?,
        sort: (any SQLOrderingTerm)?,
        batchSize: Int,
        progress: @Sendable (EnumerateProgress) -> Void,
        body: @Sendable (Model) throws -> Void
    ) throws {
        try dbWriter.read { db in
            var request = Model.all()
            if let filter { request = request.filter(filter) }
            if let sort { request = request.order(sort) }
            let cursor = try request.fetchCursor(db)
            var count = 0
            while let model = try cursor.next() {
                try body(model)
                count += 1
                if count % batchSize == 0 {
                    progress(EnumerateProgress(processed: count))
                }
            }
            if count % batchSize != 0 {
                progress(EnumerateProgress(processed: count))
            }
        }
    }
}
