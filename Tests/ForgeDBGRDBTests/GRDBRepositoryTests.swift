import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("GRDBRepository CRUD")
struct GRDBRepositoryTests {

    @Test func saveAndGet() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let record = TestRecord(name: "Test")
        try repo.save(record)
        let result = try repo.get(record.id)
        #expect(result?.name == "Test")
    }

    @Test func getReturnsNilForMissing() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        #expect(try repo.get(UUID()) == nil)
    }

    @Test func saveUpdatesExisting() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let id = UUID()
        try repo.save(TestRecord(id: id, name: "Original"))
        try repo.save(TestRecord(id: id, name: "Updated"))
        let result = try repo.get(id)
        #expect(result?.name == "Updated")
    }

    @Test func saveBatch() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let records = [TestRecord(name: "A"), TestRecord(name: "B"), TestRecord(name: "C")]
        try repo.save(records)
        #expect(try repo.count() == 3)
    }

    @Test func deleteByModel() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let record = TestRecord(name: "Test")
        try repo.save(record)
        try repo.delete(record)
        #expect(try repo.get(record.id) == nil)
    }

    @Test func deleteById() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let record = TestRecord(name: "Test")
        try repo.save(record)
        try repo.delete(record.id)
        #expect(try repo.get(record.id) == nil)
    }

    @Test func exists() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let record = TestRecord(name: "Test")
        #expect(try repo.exists(record.id) == false)
        try repo.save(record)
        #expect(try repo.exists(record.id) == true)
    }

    @Test func fetchAll() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))
        #expect(try repo.fetchAll().count == 2)
    }

    @Test func deleteAll() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))
        try repo.deleteAll()
        #expect(try repo.count() == 0)
    }

    @Test func count() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        #expect(try repo.count() == 0)
        try repo.save(TestRecord(name: "A"))
        #expect(try repo.count() == 1)
    }

    @Test func transaction() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.transaction {
            try repo.save(TestRecord(name: "A"))
            try repo.save(TestRecord(name: "B"))
        }
        #expect(try repo.count() == 2)
    }

    @Test func transactionRollbackOnError() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "Existing"))

        struct TestError: Error {}
        #expect(throws: TestError.self) {
            try repo.transaction {
                try repo.save(TestRecord(name: "New"))
                throw TestError()
            }
        }
        #expect(try repo.count() == 1)
    }
}
