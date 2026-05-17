import Foundation

public enum HistoryAction: String, Codable, Sendable {
    case insert
    case update
    case delete
}
