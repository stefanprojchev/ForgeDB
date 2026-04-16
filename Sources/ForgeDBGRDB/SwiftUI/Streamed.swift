import SwiftUI
import GRDB
import ForgeDB

/// Internal observable object that holds the stream subscription and current items.
@MainActor
private final class StreamedObserver<Model>: ObservableObject
where Model: Codable & Sendable & Identifiable & FetchableRecord & PersistableRecord,
      Model.ID: DatabaseValueConvertible & Sendable
{
    @Published var items: [Model] = []
    private var streamTask: Task<Void, Never>?

    func start(stream: AsyncStream<[Model]>) {
        guard streamTask == nil else { return }
        streamTask = Task { [weak self] in
            for await newItems in stream {
                self?.items = newItems
            }
        }
    }

    deinit {
        streamTask?.cancel()
    }
}

/// A SwiftUI property wrapper that streams repository results into a view.
/// Wraps a GRDBRepository's `stream()` into @StateObject-backed live-updating data.
///
/// Usage:
/// ```
/// struct PostListView: View {
///     @Streamed var posts: [Post]
///
///     init(repo: GRDBRepository<Post>) {
///         _posts = Streamed(repo)
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public struct Streamed<Model>: @preconcurrency DynamicProperty
where Model: Codable & Sendable & Identifiable & FetchableRecord & PersistableRecord,
      Model.ID: DatabaseValueConvertible & Sendable
{
    @StateObject private var observer: StreamedObserver<Model>

    private let stream: AsyncStream<[Model]>

    public init(
        _ repo: GRDBRepository<Model>,
        filter: (any SQLSpecificExpressible)? = nil,
        sort: (any SQLOrderingTerm)? = nil
    ) {
        let s = repo.stream(filter: filter, sort: sort)
        self.stream = s
        _observer = StateObject(wrappedValue: StreamedObserver())
    }

    public var wrappedValue: [Model] {
        observer.items
    }

    public func update() {
        observer.start(stream: stream)
    }
}
