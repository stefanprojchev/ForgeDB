import Testing
import Foundation
@testable import ForgeDB

@Suite("DBError")
struct DBErrorTests {

    @Test func validTableNames() throws {
        try validateTableName("users")
        try validateTableName("user_posts")
        try validateTableName("_private")
        try validateTableName("Table123")
    }

    @Test func invalidTableNames() {
        #expect(throws: DBError.self) { try validateTableName("") }
        #expect(throws: DBError.self) { try validateTableName("has space") }
        #expect(throws: DBError.self) { try validateTableName("123start") }
        #expect(throws: DBError.self) { try validateTableName("drop;table") }
        #expect(throws: DBError.self) { try validateTableName("name\"quote") }
        #expect(throws: DBError.self) { try validateTableName("\"; DROP TABLE users--") }
    }
}
