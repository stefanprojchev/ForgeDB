# ForgeDB

Type-safe repository pattern and GRDB-backed SQLite persistence for iOS.

![Swift 6.3+](https://img.shields.io/badge/Swift-6.3+-orange.svg)
![iOS 18+](https://img.shields.io/badge/iOS-18+-blue.svg)
![macOS 15+](https://img.shields.io/badge/macOS-15+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
[![Release](https://img.shields.io/github/v/release/stefanprojchev/ForgeDB)](https://github.com/stefanprojchev/ForgeDB/releases)

---

ForgeDB gives you a clean, testable `Repository<Model>` protocol plus a production GRDB/SQLite implementation packed with the operations you actually need — pagination, soft delete, upsert, FTS, history, archiving, aggregations, and live SwiftUI streams — without leaking GRDB into your domain layer.

## Libraries

| Library | Contents | Use for |
|---|---|---|
| **ForgeDB** | `Repository` protocol, marker protocols (`Timestampable`, `SoftDeletable`, `Expirable`, `Archivable`), `InMemoryRepository`, `DBError` | Domain layer — depend on this from your models and services |
| **ForgeDBGRDB** | `DatabaseManager`, `GRDBRepository`, `QueryableRepository`, `@Streamed` property wrapper, extensions | Infrastructure layer — wire up at the composition root |

## Features

- **Protocol-first** — your domain depends on `Repository<Model>`, not on GRDB
- **In-memory test double** — `InMemoryRepository` for fast, deterministic tests
- **Rich query surface** — filter, sort, paginate, aggregate, full-text search, associations
- **Marker protocols** — opt models into timestamps, soft delete, expiration, and archiving with conforming types
- **Reactive** — `stream()` returns an `AsyncStream<[Model]>` that emits on every write
- **SwiftUI** — `@Streamed` property wrapper feeds live results straight into a view
- **Batch operations** — `enumerate(batchSize:)`, batch progress, and import strategies (`insert`, `upsert`, `replace`)
- **History & archive** — record-level history queries, archival workflows, export helpers
- **Operational tooling** — schema validation, query logging, database stats, reset, seed
- **Encryption-ready API** — `DatabaseEncryption` defines the surface for SQLCipher integration

## Requirements

- **iOS** 18+
- **macOS** 15+
- **Swift** 6.3+ (Xcode 26 or later)

## Installation

### Xcode

1. **File → Add Package Dependencies…**
2. Paste `https://github.com/stefanprojchev/ForgeDB.git`
3. Set rule to **Up to Next Major** from `1.0.0`

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/stefanprojchev/ForgeDB.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourDomain",
        dependencies: [
            .product(name: "ForgeDB", package: "ForgeDB"),
        ]
    ),
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ForgeDBGRDB", package: "ForgeDB"),
        ]
    ),
]
```

Keep `ForgeDB` in your domain target and `ForgeDBGRDB` at the composition root — your domain stays GRDB-free.

## Quick Start

### Define a model

```swift
import GRDB
import ForgeDB

struct Post: Codable, Identifiable, Sendable,
             FetchableRecord, PersistableRecord,
             Timestampable {
    var id: String
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
}
```

### Set up the database

```swift
import ForgeDBGRDB

let manager = try DatabaseManager(
    name: "app",
    directory: URL.documentsDirectory
) { migrator in
    migrator.registerMigration("v1") { db in
        try db.create(table: "post") { t in
            t.column("id", .text).primaryKey()
            t.column("title", .text).notNull()
            t.column("body", .text).notNull()
            t.column("createdAt", .datetime).notNull()
            t.column("updatedAt", .datetime).notNull()
        }
    }
}

let posts = GRDBRepository<Post>(manager: manager)
```

### Use the repository

```swift
try posts.save(Post(id: "1", title: "Hello", body: "...", createdAt: .now, updatedAt: .now))

let post = try posts.get("1")
let all = try posts.fetchAll()
let count = try posts.count()

try posts.transaction {
    try posts.save(a)
    try posts.save(b)
}
```

### Query with filters

```swift
let recent = try posts.fetch(
    filter: Column("createdAt") > Date().addingTimeInterval(-86_400),
    sort: Column("createdAt").desc,
    limit: 20
)
```

### Live SwiftUI

```swift
import SwiftUI
import ForgeDBGRDB

struct PostListView: View {
    @Streamed var items: [Post]

    init(repo: GRDBRepository<Post>) {
        _items = Streamed(repo)
    }

    var body: some View {
        List(items) { post in
            Text(post.title)
        }
    }
}
```

## Testing

Swap the production repository for `InMemoryRepository` in tests — no SQLite, no I/O:

```swift
import Testing
import ForgeDB

@Test
func savesAndFetchesPosts() throws {
    let repo: any Repository<Post> = InMemoryRepository()

    try repo.save(Post(id: "1", title: "Hello", body: "...", createdAt: .now, updatedAt: .now))

    #expect(try repo.count() == 1)
    #expect(try repo.get("1")?.title == "Hello")
}
```

## The Forge Family

ForgeDB is part of the **Forge** family of Swift packages for iOS.

| Package | Description |
|---|---|
| [ForgeCore](https://github.com/stefanprojchev/ForgeCore) | Thread-safe primitives for iOS Swift packages. |
| [ForgeInject](https://github.com/stefanprojchev/ForgeInject) | Dependency injection with constructor and property wrapper support. |
| [ForgeObservers](https://github.com/stefanprojchev/ForgeObservers) | Reactive system observers — connectivity, lifecycle, keyboard, and more. |
| [ForgeStorage](https://github.com/stefanprojchev/ForgeStorage) | Type-safe key-value, file, and Keychain storage. |
| **ForgeDB** | Type-safe repository pattern and GRDB-backed SQLite persistence. |
| [ForgeOrchestrator](https://github.com/stefanprojchev/ForgeOrchestrator) | Orchestrate app flows — startup gates, data pipelines, and continuous monitors. |
| [ForgePush](https://github.com/stefanprojchev/ForgePush) | Push notification management — permissions, tokens, and routing. |
| [ForgeLocation](https://github.com/stefanprojchev/ForgeLocation) | Location triggers — geofencing, significant changes, and visits. |
| [ForgeBackgroundTasks](https://github.com/stefanprojchev/ForgeBackgroundTasks) | Background task scheduling and dispatch. |

## License

ForgeDB is released under the MIT License. See [LICENSE](LICENSE).
