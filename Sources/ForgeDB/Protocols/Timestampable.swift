import Foundation

public protocol Timestampable {
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}
