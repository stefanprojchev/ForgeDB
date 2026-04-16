import Testing
import Foundation
import GRDB
@testable import ForgeDBGRDB

struct Author: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "author"
    var id: UUID
    var name: String

    static let books = hasMany(Book.self)

    enum Column: String, CodingKey, ColumnExpression {
        case id, name
    }

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct Book: Codable, Sendable, Identifiable, Equatable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "book"
    var id: UUID
    var title: String
    var authorId: UUID

    static let author = belongsTo(Author.self)

    enum Column: String, CodingKey, ColumnExpression {
        case id, title, authorId
    }

    init(id: UUID = UUID(), title: String, authorId: UUID) {
        self.id = id
        self.title = title
        self.authorId = authorId
    }
}

func makeAssociationManager() throws -> DatabaseManager {
    try DatabaseManager.inMemory { migrator in
        migrator.registerMigration("v1") { db in
            try db.create(table: "author") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
            }
            try db.create(table: "book") { t in
                t.primaryKey("id", .text)
                t.column("title", .text).notNull()
                t.column("authorId", .text).notNull().references("author", onDelete: .cascade)
            }
        }
    }
}

@Suite("Associations")
struct AssociationTests {

    @Test func fetchWithChildren() throws {
        let manager = try makeAssociationManager()
        let authorRepo = GRDBRepository<Author>(manager: manager)
        let bookRepo = GRDBRepository<Book>(manager: manager)

        let author = Author(name: "Stefan")
        try authorRepo.save(author)
        try bookRepo.save(Book(title: "Book A", authorId: author.id))
        try bookRepo.save(Book(title: "Book B", authorId: author.id))

        let results = try authorRepo.fetchWithChildren(Author.books)
        #expect(results.count == 1)
        #expect(results[0].children.count == 2)
    }

    @Test func fetchWithParent() throws {
        let manager = try makeAssociationManager()
        let authorRepo = GRDBRepository<Author>(manager: manager)
        let bookRepo = GRDBRepository<Book>(manager: manager)

        let author = Author(name: "Stefan")
        try authorRepo.save(author)
        let book = Book(title: "Book A", authorId: author.id)
        try bookRepo.save(book)

        let results = try bookRepo.fetchWithParent(Book.author)
        #expect(results.count == 1)
        #expect(results[0].parent?.name == "Stefan")
    }
}
