import Foundation

public struct DBStats: Sendable {
    public let fileSizeBytes: UInt64
    public let tables: [TableStats]
}
