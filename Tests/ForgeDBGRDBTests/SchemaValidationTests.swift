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
}
