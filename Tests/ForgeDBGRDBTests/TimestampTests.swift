import Testing
import Foundation
import GRDB
import ForgeDB
@testable import ForgeDBGRDB

@Suite("Timestamps")
struct TimestampTests {

    @Test func saveSetsBothTimestampsOnInsert() throws {
        let repo = try GRDBRepository<TimestampRecord>(manager: makeTimestampManager())
        let record = TimestampRecord(name: "Test")
        try repo.saveWithTimestamps(record)
        let saved = try repo.get(record.id)!
        #expect(saved.createdAt != .distantPast)
        #expect(saved.updatedAt != .distantPast)
    }

    @Test func saveUpdatesOnlyUpdatedAtOnUpdate() throws {
        let repo = try GRDBRepository<TimestampRecord>(manager: makeTimestampManager())
        let record = TimestampRecord(name: "Test")
        try repo.saveWithTimestamps(record)
        let firstSave = try repo.get(record.id)!
        let createdAt = firstSave.createdAt

        Thread.sleep(forTimeInterval: 0.01)

        var updated = firstSave
        updated.name = "Updated"
        try repo.saveWithTimestamps(updated)
        let secondSave = try repo.get(record.id)!

        #expect(secondSave.createdAt == createdAt)
        #expect(secondSave.updatedAt > createdAt)
    }
}
