import Testing
import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

@Suite("Archive")
struct ArchiveTests {

    @Test func archive() throws {
        let repo = try GRDBRepository<ArchivableRecord>(manager: makeArchivableManager())
        let record = ArchivableRecord(name: "Test")
        try repo.save(record)
        try repo.archive(record)
        let result = try repo.get(record.id)
        #expect(result?.archivedAt != nil)
    }

    @Test func unarchive() throws {
        let repo = try GRDBRepository<ArchivableRecord>(manager: makeArchivableManager())
        let record = ArchivableRecord(name: "Test")
        try repo.save(record)
        try repo.archive(record)

        let archived = try repo.get(record.id)!
        try repo.unarchive(archived)

        let result = try repo.get(record.id)
        #expect(result?.archivedAt == nil)
    }

    @Test func fetchActiveExcludesArchived() throws {
        let repo = try GRDBRepository<ArchivableRecord>(manager: makeArchivableManager())
        try repo.save(ArchivableRecord(name: "Active"))
        let archived = ArchivableRecord(name: "Archived")
        try repo.save(archived)
        try repo.archive(archived)

        let active = try repo.fetchActive()
        #expect(active.count == 1)
        #expect(active[0].name == "Active")
    }

    @Test func fetchArchived() throws {
        let repo = try GRDBRepository<ArchivableRecord>(manager: makeArchivableManager())
        try repo.save(ArchivableRecord(name: "Active"))
        let archived = ArchivableRecord(name: "Archived")
        try repo.save(archived)
        try repo.archive(archived)

        let result = try repo.fetchArchived()
        #expect(result.count == 1)
        #expect(result[0].name == "Archived")
    }

    @Test func archiveWithFilter() throws {
        let repo = try GRDBRepository<ArchivableRecord>(manager: makeArchivableManager())
        try repo.save(ArchivableRecord(name: "Keep"))
        try repo.save(ArchivableRecord(name: "Archive Me"))
        try repo.save(ArchivableRecord(name: "Archive Me Too"))

        try repo.archive(filter: ArchivableRecord.Column.name != "Keep")

        let active = try repo.fetchActive()
        #expect(active.count == 1)
        #expect(active[0].name == "Keep")

        let archived = try repo.fetchArchived()
        #expect(archived.count == 2)
    }
}
