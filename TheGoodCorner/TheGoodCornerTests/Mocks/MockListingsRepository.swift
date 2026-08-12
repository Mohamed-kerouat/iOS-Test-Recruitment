import Foundation
@testable import TheGoodCorner

@MainActor
final class MockListingsRepository: ListingsRepositoryProtocol {
    var fetchListingsCallCount = 0
    var fetchCategoriesCallCount = 0

    var listingsResult: Result<ListingsResponse, Error> = .success(
        ListingsResponse(total: 0, items: [], limit: 20, hasMore: false, page: 1)
    )
    var categoriesResult: Result<[TheGoodCorner.Category], Error> = .success([])

    func fetchListings() async throws -> ListingsResponse {
        fetchListingsCallCount += 1
        return try listingsResult.get()
    }

    func fetchCategories() async throws -> [TheGoodCorner.Category] {
        fetchCategoriesCallCount += 1
        return try categoriesResult.get()
    }
}
