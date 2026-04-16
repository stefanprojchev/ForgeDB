import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("QueryableRepository")
struct QueryableRepositoryTests {

    @Test func fetchWithFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", isActive: true))
        try repo.save(TestRecord(name: "B", isActive: false))
        try repo.save(TestRecord(name: "C", isActive: true))

        let active = try repo.fetch(
            filter: TestRecord.Column.isActive == true,
            sort: nil,
            limit: nil
        )
        #expect(active.count == 2)
    }

    @Test func fetchWithSort() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "B", score: 20))
        try repo.save(TestRecord(name: "A", score: 10))
        try repo.save(TestRecord(name: "C", score: 30))

        let sorted = try repo.fetch(
            filter: nil,
            sort: TestRecord.Column.score.asc,
            limit: nil
        )
        #expect(sorted.map(\.name) == ["A", "B", "C"])
    }

    @Test func fetchWithLimit() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))
        try repo.save(TestRecord(name: "C"))

        let limited = try repo.fetch(filter: nil, sort: nil, limit: 2)
        #expect(limited.count == 2)
    }

    @Test func fetchWithFilterSortLimit() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", score: 30, isActive: true))
        try repo.save(TestRecord(name: "B", score: 10, isActive: true))
        try repo.save(TestRecord(name: "C", score: 20, isActive: false))
        try repo.save(TestRecord(name: "D", score: 40, isActive: true))

        let result = try repo.fetch(
            filter: TestRecord.Column.isActive == true,
            sort: TestRecord.Column.score.desc,
            limit: 2
        )
        #expect(result.map(\.name) == ["D", "A"])
    }

    @Test func first() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", score: 10))
        try repo.save(TestRecord(name: "B", score: 20))

        let top = try repo.first(
            filter: nil,
            sort: TestRecord.Column.score.desc
        )
        #expect(top?.name == "B")
    }

    @Test func firstReturnsNil() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let result = try repo.first(filter: TestRecord.Column.name == "missing", sort: nil)
        #expect(result == nil)
    }

    @Test func countWithFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", isActive: true))
        try repo.save(TestRecord(name: "B", isActive: false))

        let activeCount = try repo.count(filter: TestRecord.Column.isActive == true)
        #expect(activeCount == 1)
    }

    @Test func deleteWithFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", isActive: true))
        try repo.save(TestRecord(name: "B", isActive: false))

        try repo.delete(filter: TestRecord.Column.isActive == false)
        #expect(try repo.count() == 1)
        #expect(try repo.fetchAll().first?.name == "A")
    }

    @Test func enumerate() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A"))
        try repo.save(TestRecord(name: "B"))
        try repo.save(TestRecord(name: "C"))

        // nonisolated(unsafe) allows mutation of `names` inside the @Sendable closure.
        // enumerate is synchronous and single-threaded (runs on GRDB's read queue),
        // so this is safe in practice.
        nonisolated(unsafe) var names: [String] = []
        try repo.enumerate(filter: nil, sort: TestRecord.Column.name.asc, batchSize: 100) { record in
            names.append(record.name)
        }
        #expect(names == ["A", "B", "C"])
    }
}
