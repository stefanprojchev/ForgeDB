import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("Upsert")
struct UpsertTests {

    @Test func upsertInsertsNew() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let record = TestRecord(name: "New")
        try repo.upsert(record)
        #expect(try repo.count() == 1)
        #expect(try repo.get(record.id)?.name == "New")
    }

    @Test func upsertUpdatesExisting() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let id = UUID()
        try repo.save(TestRecord(id: id, name: "Original"))
        try repo.upsert(TestRecord(id: id, name: "Updated"))
        #expect(try repo.count() == 1)
        #expect(try repo.get(id)?.name == "Updated")
    }

    @Test func batchUpsert() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let id1 = UUID(), id2 = UUID()
        try repo.save(TestRecord(id: id1, name: "Existing"))
        try repo.upsert([
            TestRecord(id: id1, name: "Updated"),
            TestRecord(id: id2, name: "New"),
        ])
        #expect(try repo.count() == 2)
        #expect(try repo.get(id1)?.name == "Updated")
        #expect(try repo.get(id2)?.name == "New")
    }
}
