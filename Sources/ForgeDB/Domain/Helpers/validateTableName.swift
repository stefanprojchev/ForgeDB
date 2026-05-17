import Foundation

/// Validates that a table name contains only safe identifier characters.
/// Rejects anything that doesn't match `^[a-zA-Z_][a-zA-Z0-9_]*$`.
public func validateTableName(_ name: String) throws {
    let pattern = /^[a-zA-Z_][a-zA-Z0-9_]*$/
    guard name.wholeMatch(of: pattern) != nil else {
        throw DBError.invalidTableName(name)
    }
}
