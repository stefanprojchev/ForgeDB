import Testing
import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

@Suite("SoftDelete")
struct SoftDeleteTests {

    @Test func softDelete() throws {
        let repo = try GRDBRepository<SoftDeleteRecord>(manager: makeSoftDeleteManager())
        let record = SoftDeleteRecord(name: "Test")
        try repo.save(record)
        try repo.softDelete(record)
        let result = try repo.get(record.id)
        #expect(result?.isDeleted == true)
        #expect(result?.deletedAt != nil)
    }

    @Test func fetchExcludesSoftDeleted() throws {
        let repo = try GRDBRepository<SoftDeleteRecord>(manager: makeSoftDeleteManager())
        try repo.save(SoftDeleteRecord(name: "Active"))
        let deleted = SoftDeleteRecord(name: "Deleted")
        try repo.save(deleted)
        try repo.softDelete(deleted)

        let active = try repo.fetchActive()
        #expect(active.count == 1)
        #expect(active[0].name == "Active")
    }

    @Test func fetchDeleted() throws {
        let repo = try GRDBRepository<SoftDeleteRecord>(manager: makeSoftDeleteManager())
        try repo.save(SoftDeleteRecord(name: "Active"))
        let deleted = SoftDeleteRecord(name: "Deleted")
        try repo.save(deleted)
        try repo.softDelete(deleted)

        let result = try repo.fetchDeleted()
        #expect(result.count == 1)
        #expect(result[0].name == "Deleted")
    }

    @Test func restore() throws {
        let repo = try GRDBRepository<SoftDeleteRecord>(manager: makeSoftDeleteManager())
        let record = SoftDeleteRecord(name: "Test")
        try repo.save(record)
        try repo.softDelete(record)
        try repo.restore(record)
        let result = try repo.get(record.id)
        #expect(result?.isDeleted == false)
        #expect(result?.deletedAt == nil)
    }

    @Test func purge() throws {
        let repo = try GRDBRepository<SoftDeleteRecord>(manager: makeSoftDeleteManager())
        try repo.save(SoftDeleteRecord(name: "Active"))
        let deleted = SoftDeleteRecord(name: "Deleted")
        try repo.save(deleted)
        try repo.softDelete(deleted)

        try repo.purge()
        #expect(try repo.count() == 1)
    }
}
