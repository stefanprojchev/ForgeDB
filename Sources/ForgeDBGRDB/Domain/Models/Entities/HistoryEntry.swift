import Foundation

public struct HistoryEntry<Model: Codable & Sendable>: Codable, Sendable {
    public let snapshot: Model
    public let changedAt: Date
    public let action: HistoryAction
}
