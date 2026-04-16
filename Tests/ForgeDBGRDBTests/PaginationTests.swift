import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("Pagination")
struct PaginationTests {

    private func seedRepo(count: Int) throws -> GRDBRepository<TestRecord> {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        for i in 0..<count {
            try repo.save(TestRecord(name: "Item \(i)", score: i))
        }
        return repo
    }

    @Test func firstPage() throws {
        let repo = try seedRepo(count: 25)
        let page = try repo.fetch(filter: nil, sort: TestRecord.Column.score.asc, page: 1, pageSize: 10)
        #expect(page.items.count == 10)
        #expect(page.page == 1)
        #expect(page.totalCount == 25)
        #expect(page.totalPages == 3)
        #expect(page.hasNextPage == true)
        #expect(page.hasPreviousPage == false)
    }

    @Test func lastPage() throws {
        let repo = try seedRepo(count: 25)
        let page = try repo.fetch(filter: nil, sort: TestRecord.Column.score.asc, page: 3, pageSize: 10)
        #expect(page.items.count == 5)
        #expect(page.hasNextPage == false)
        #expect(page.hasPreviousPage == true)
    }

    @Test func withFilter() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        for i in 0..<20 {
            try repo.save(TestRecord(name: "Item \(i)", score: i, isActive: i % 2 == 0))
        }
        let page = try repo.fetch(
            filter: TestRecord.Column.isActive == true,
            sort: TestRecord.Column.score.asc,
            page: 1,
            pageSize: 5
        )
        #expect(page.totalCount == 10)
        #expect(page.items.count == 5)
        #expect(page.totalPages == 2)
    }

    @Test func emptyResult() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let page = try repo.fetch(filter: nil, sort: nil, page: 1, pageSize: 10)
        #expect(page.items.isEmpty)
        #expect(page.totalCount == 0)
        #expect(page.totalPages == 0)
        #expect(page.hasNextPage == false)
        #expect(page.hasPreviousPage == false)
    }
}
