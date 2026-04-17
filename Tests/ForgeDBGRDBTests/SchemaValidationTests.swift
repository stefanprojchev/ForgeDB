import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("SchemaValidation")
struct SchemaValidationTests {

    @Test func validateSchemaSucceeds() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.validateSchema()
    }

    @Test func validateSchemaComparesColumnsWhenDataExists() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        try repo.save(TestRecord(name: "Test"))
        try repo.validateSchema()
    }
}
