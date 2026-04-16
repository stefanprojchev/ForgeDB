import Foundation

public protocol Expirable {
    var expiresAt: Date { get set }
}
