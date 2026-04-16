import Foundation
import GRDB
import ForgeDB

extension GRDBRepository {
    /// Load initial data from a bundled JSON file.
    /// Only inserts records that don't already exist (safe to call on every launch).
    public func seed(from bundle: Bundle, fileName: String) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw DBError.fetchFailed(underlying: "Seed file not found: \(fileName)")
        }
        let data = try Data(contentsOf: url)
        let models = try JSONDecoder().decode([Model].self, from: data)
        try dbWriter.unsafeReentrantWrite { db in
            for model in models {
                if try !Model.exists(db, key: model.id) {
                    try model.insert(db)
                }
            }
        }
    }
}
