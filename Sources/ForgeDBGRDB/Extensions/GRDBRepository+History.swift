import Foundation
import GRDB
import ForgeDB

public struct HistoryEntry<Model: Codable & Sendable>: Codable, Sendable {
    public let snapshot: Model
    public let changedAt: Date
    public let action: HistoryAction
}

public enum HistoryAction: String, Codable, Sendable {
    case insert
    case update
    case delete
}

extension GRDBRepository {
    /// Save model and record a history entry in the companion `_history` table.
    /// The history table must be created in migrations with columns:
    /// `id` (text, primary key), `modelId` (text), `snapshot` (text/blob), `changedAt` (datetime), `action` (text)
    public func saveWithHistory(_ model: Model, historyTable: String? = nil) throws {
        let tableName = historyTable ?? "\(Model.databaseTableName)_history"
        try validateTableName(tableName)
        let snapshotData = try JSONEncoder().encode(model)
        let snapshotString = String(data: snapshotData, encoding: .utf8) ?? ""
        try dbWriter.write { db in
            let isInsert = try !self._exists(model.id, in: db)
            try self._save(model, in: db)
            let action: HistoryAction = isInsert ? .insert : .update
            try db.execute(
                sql: "INSERT INTO \"\(tableName)\" (id, modelId, snapshot, changedAt, action) VALUES (?, ?, ?, ?, ?)",
                arguments: [UUID().uuidString, "\(model.id)", snapshotString, Date.now, action.rawValue]
            )
        }
    }

    public func history(for id: Model.ID, limit: Int? = nil, historyTable: String? = nil) throws -> [HistoryEntry<Model>] {
        let tableName = historyTable ?? "\(Model.databaseTableName)_history"
        try validateTableName(tableName)
        return try dbWriter.read { db in
            var sql = "SELECT snapshot, changedAt, action FROM \"\(tableName)\" WHERE modelId = ? ORDER BY rowid DESC"
            if let limit { sql += " LIMIT \(limit)" }
            let rows = try Row.fetchAll(db, sql: sql, arguments: ["\(id)"])
            return try rows.compactMap { row in
                guard let snapshotString: String = row["snapshot"],
                      let snapshotData = snapshotString.data(using: .utf8),
                      let changedAt: Date = row["changedAt"],
                      let actionRaw: String = row["action"],
                      let action = HistoryAction(rawValue: actionRaw) else { return nil }
                let snapshot = try JSONDecoder().decode(Model.self, from: snapshotData)
                return HistoryEntry(snapshot: snapshot, changedAt: changedAt, action: action)
            }
        }
    }
}
