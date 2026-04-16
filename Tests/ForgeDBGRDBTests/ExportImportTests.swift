import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("Export/Import")
struct ExportImportTests {

    @Test func exportAndImportRoundTrip() throws {
        let repo1 = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo1.save(TestRecord(name: "A", score: 10))
        try repo1.save(TestRecord(name: "B", score: 20))

        let json = try repo1.exportJSON()

        let repo2 = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo2.importJSON(json, strategy: .insert)
        #expect(try repo2.count() == 2)
    }

    @Test func importUpsert() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let id = UUID()
        try repo.save(TestRecord(id: id, name: "Original", score: 10))

        let updated = [TestRecord(id: id, name: "Updated", score: 99)]
        let json = try JSONEncoder().encode(updated)
        try repo.importJSON(json, strategy: .upsert)

        #expect(try repo.count() == 1)
        #expect(try repo.get(id)?.name == "Updated")
    }

    @Test func importReplace() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "Old1"))
        try repo.save(TestRecord(name: "Old2"))

        let newRecords = [TestRecord(name: "New1")]
        let json = try JSONEncoder().encode(newRecords)
        try repo.importJSON(json, strategy: .replace)

        #expect(try repo.count() == 1)
        #expect(try repo.fetchAll().first?.name == "New1")
    }

    @Test func exportWithFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "Active", isActive: true))
        try repo.save(TestRecord(name: "Inactive", isActive: false))

        let json = try repo.exportJSON(filter: TestRecord.Column.isActive == true)
        let decoded = try JSONDecoder().decode([TestRecord].self, from: json)
        #expect(decoded.count == 1)
        #expect(decoded[0].name == "Active")
    }
}
