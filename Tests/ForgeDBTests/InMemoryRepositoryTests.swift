import Testing
import Foundation
@testable import ForgeDB

struct TestItem: Codable, Sendable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var value: Int

    init(id: UUID = UUID(), name: String, value: Int = 0) {
        self.id = id
        self.name = name
        self.value = value
    }
}

@Suite("InMemoryRepository")
struct InMemoryRepositoryTests {

    @Test func saveAndGet() throws {
        let repo = InMemoryRepository<TestItem>()
        let item = TestItem(name: "Test")
        try repo.save(item)
        let result = try repo.get(item.id)
        #expect(result == item)
    }

    @Test func getReturnsNilForMissing() throws {
        let repo = InMemoryRepository<TestItem>()
        let result = try repo.get(UUID())
        #expect(result == nil)
    }

    @Test func saveOverwritesExisting() throws {
        let repo = InMemoryRepository<TestItem>()
        let id = UUID()
        try repo.save(TestItem(id: id, name: "Original"))
        try repo.save(TestItem(id: id, name: "Updated"))
        let result = try repo.get(id)
        #expect(result?.name == "Updated")
    }

    @Test func saveBatch() throws {
        let repo = InMemoryRepository<TestItem>()
        let items = [TestItem(name: "A"), TestItem(name: "B"), TestItem(name: "C")]
        try repo.save(items)
        #expect(try repo.count() == 3)
    }

    @Test func deleteByModel() throws {
        let repo = InMemoryRepository<TestItem>()
        let item = TestItem(name: "Test")
        try repo.save(item)
        try repo.delete(item)
        #expect(try repo.get(item.id) == nil)
    }

    @Test func deleteById() throws {
        let repo = InMemoryRepository<TestItem>()
        let item = TestItem(name: "Test")
        try repo.save(item)
        try repo.delete(item.id)
        #expect(try repo.get(item.id) == nil)
    }

    @Test func exists() throws {
        let repo = InMemoryRepository<TestItem>()
        let item = TestItem(name: "Test")
        #expect(try repo.exists(item.id) == false)
        try repo.save(item)
        #expect(try repo.exists(item.id) == true)
    }

    @Test func fetchAll() throws {
        let repo = InMemoryRepository<TestItem>()
        try repo.save(TestItem(name: "A"))
        try repo.save(TestItem(name: "B"))
        #expect(try repo.fetchAll().count == 2)
    }

    @Test func deleteAll() throws {
        let repo = InMemoryRepository<TestItem>()
        try repo.save(TestItem(name: "A"))
        try repo.save(TestItem(name: "B"))
        try repo.deleteAll()
        #expect(try repo.count() == 0)
    }

    @Test func count() throws {
        let repo = InMemoryRepository<TestItem>()
        #expect(try repo.count() == 0)
        try repo.save(TestItem(name: "A"))
        #expect(try repo.count() == 1)
    }

    @Test func transaction() throws {
        let repo = InMemoryRepository<TestItem>()
        try repo.transaction {
            try repo.save(TestItem(name: "A"))
            try repo.save(TestItem(name: "B"))
        }
        #expect(try repo.count() == 2)
    }

    @Test func initWithSeed() throws {
        let items = [TestItem(name: "A"), TestItem(name: "B")]
        let repo = InMemoryRepository(items)
        #expect(try repo.count() == 2)
    }
}
