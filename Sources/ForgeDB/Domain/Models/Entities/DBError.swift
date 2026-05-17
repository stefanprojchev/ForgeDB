import Foundation

/// ForgeDB-specific error conditions.
/// GRDB errors (constraint violations, SQL errors, etc.) pass through unwrapped.
/// DBError is used for ForgeDB-level validation and domain errors.
public enum DBError: LocalizedError, Sendable {
    case modelNotFound(id: String)
    case saveFailed(underlying: String)
    case deleteFailed(underlying: String)
    case fetchFailed(underlying: String)
    case migrationFailed(underlying: String)
    case transactionFailed(underlying: String)
    case invalidTableName(String)

    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let id):
            "Model not found with id: \(id)"
        case .saveFailed(let underlying):
            "Save failed: \(underlying)"
        case .deleteFailed(let underlying):
            "Delete failed: \(underlying)"
        case .fetchFailed(let underlying):
            "Fetch failed: \(underlying)"
        case .migrationFailed(let underlying):
            "Migration failed: \(underlying)"
        case .transactionFailed(let underlying):
            "Transaction failed: \(underlying)"
        case .invalidTableName(let name):
            "Invalid table name: '\(name)'. Table names must match [a-zA-Z_][a-zA-Z0-9_]*"
        }
    }
}
