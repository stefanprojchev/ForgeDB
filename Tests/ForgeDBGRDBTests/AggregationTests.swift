import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("Aggregations")
struct AggregationTests {

    private func seedRepo() throws -> GRDBRepository<TestRecord> {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", score: 10))
        try repo.save(TestRecord(name: "B", score: 20))
        try repo.save(TestRecord(name: "C", score: 30))
        return repo
    }

    @Test func sum() throws {
        let repo = try seedRepo()
        let total: Int? = try repo.sum(TestRecord.Column.score)
        #expect(total == 60)
    }

    @Test func average() throws {
        let repo = try seedRepo()
        let avg = try repo.average(TestRecord.Column.score)
        #expect(avg == 20.0)
    }

    @Test func min() throws {
        let repo = try seedRepo()
        let minimum: Int? = try repo.min(TestRecord.Column.score)
        #expect(minimum == 10)
    }

    @Test func max() throws {
        let repo = try seedRepo()
        let maximum: Int? = try repo.max(TestRecord.Column.score)
        #expect(maximum == 30)
    }

    @Test func sumWithFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "A", score: 10, isActive: true))
        try repo.save(TestRecord(name: "B", score: 20, isActive: false))
        try repo.save(TestRecord(name: "C", score: 30, isActive: true))

        let total: Int? = try repo.sum(TestRecord.Column.score, filter: TestRecord.Column.isActive == true)
        #expect(total == 40)
    }

    @Test func aggregateOnEmpty() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let total: Int? = try repo.sum(TestRecord.Column.score)
        #expect(total == nil)
    }
}
