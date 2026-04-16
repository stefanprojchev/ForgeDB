import Testing
import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

@Suite("ComputedColumns")
struct ComputedColumnsTests {

    @Test func saveRecomputesFields() throws {
        let repo = try GRDBRepository<ComputedRecord>(manager: makeComputedManager())
        let record = ComputedRecord(firstName: "Stefan", lastName: "Projchev")
        try repo.saveWithRecompute(record)

        let saved = try repo.get(record.id)!
        #expect(saved.fullName == "Stefan Projchev")
        #expect(saved.searchableText == "stefan projchev")
    }

    @Test func saveRecomputesOnUpdate() throws {
        let repo = try GRDBRepository<ComputedRecord>(manager: makeComputedManager())
        let record = ComputedRecord(firstName: "Stefan", lastName: "Projchev")
        try repo.saveWithRecompute(record)

        var updated = try repo.get(record.id)!
        updated.lastName = "Smith"
        try repo.saveWithRecompute(updated)

        let result = try repo.get(record.id)!
        #expect(result.fullName == "Stefan Smith")
        #expect(result.searchableText == "stefan smith")
    }

    @Test func batchSaveRecomputes() throws {
        let repo = try GRDBRepository<ComputedRecord>(manager: makeComputedManager())
        let records = [
            ComputedRecord(firstName: "A", lastName: "B"),
            ComputedRecord(firstName: "C", lastName: "D"),
        ]
        try repo.saveWithRecompute(records)

        let all = try repo.fetchAll()
        #expect(all.allSatisfy { !$0.fullName.isEmpty })
    }
}
