import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

@Suite("Streamed")
struct StreamedTests {

    @Test @MainActor func canInstantiate() throws {
        let repo = try GRDBRepository<TestRecord>(manager: makeTestManager())
        let streamed = Streamed(repo)
        #expect(streamed.wrappedValue.isEmpty)
    }
}
