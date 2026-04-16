import Foundation

public protocol SoftDeletable {
    var isDeleted: Bool { get set }
    var deletedAt: Date? { get set }
}
