import Foundation

/// Configuration for database encryption.
/// Full encryption requires replacing the GRDB dependency with GRDB-encrypted (SQLCipher).
public enum DatabaseEncryption: Sendable {
    /// No encryption — standard SQLite.
    case none
    /// Encrypt with a raw passphrase.
    case key(String)
    /// Encrypt with a key stored in Keychain (service + key identifiers for ForgeCrypt lookup).
    case keyFromKeychain(service: String, key: String)
}
