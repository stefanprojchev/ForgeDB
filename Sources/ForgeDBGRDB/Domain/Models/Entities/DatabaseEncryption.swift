// TODO: Integrate with GRDB-encrypted (SQLCipher) package variant.
// This type defines the API surface; actual encryption requires replacing
// the GRDB dependency with the encrypted variant in Package.swift.

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
