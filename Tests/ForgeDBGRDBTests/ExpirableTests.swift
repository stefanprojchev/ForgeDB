import Testing
import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

@Suite("Expirable")
struct ExpirableTests {

    @Test func deleteExpired() throws {
        let repo = try GRDBRepository<ExpirableRecord>(manager: makeExpirableManager())
        try repo.save(ExpirableRecord(name: "Expired", expiresAt: .distantPast))
        try repo.save(ExpirableRecord(name: "Valid", expiresAt: .distantFuture))

        try repo.deleteExpired()
        let remaining = try repo.fetchAll()
        #expect(remaining.count == 1)
        #expect(remaining[0].name == "Valid")
    }

    @Test func fetchValid() throws {
        let repo = try GRDBRepository<ExpirableRecord>(manager: makeExpirableManager())
        try repo.save(ExpirableRecord(name: "Expired", expiresAt: .distantPast))
        try repo.save(ExpirableRecord(name: "Valid", expiresAt: .distantFuture))

        let valid = try repo.fetchValid()
        #expect(valid.count == 1)
        #expect(valid[0].name == "Valid")
    }
}
