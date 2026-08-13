import Foundation
@testable import TheGoodCorner

@MainActor
final class MockListingsRepository: ListingsRepositoryProtocol {
    var fetchListingsCallCount = 0
    var fetchCategoriesCallCount = 0
    var searchListingsCallCount = 0
    private(set) var searchQueries: [String] = []

    var listingsResult: Result<ListingsResponse, Error> = .success(
        ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
    )
    var categoriesResult: Result<[TheGoodCorner.Category], Error> = .success([])
    var searchResult: Result<ListingsResponse, Error> = .success(
        ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
    )

    /// Optional artificial delay (in nanoseconds) applied before `searchListings`
    /// returns, used to keep a request "in flight" so cancellation can be exercised.
    var searchDelayNanoseconds: UInt64 = 0

    /// Per-query results take precedence over `searchResult` when a matching key exists.
    var searchResultsByQuery: [String: Result<ListingsResponse, Error>] = [:]

    var lastSearchQuery: String? { searchQueries.last }

    func fetchListings() async throws -> ListingsResponse {
        fetchListingsCallCount += 1
        return try listingsResult.get()
    }

    func fetchCategories() async throws -> [TheGoodCorner.Category] {
        fetchCategoriesCallCount += 1
        return try categoriesResult.get()
    }

    func searchListings(query: String) async throws -> ListingsResponse {
        searchListingsCallCount += 1
        searchQueries.append(query)

        if searchDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: searchDelayNanoseconds)
        }

        if let scoped = searchResultsByQuery[query] {
            return try scoped.get()
        }

        return try searchResult.get()
    }
}
