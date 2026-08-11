import XCTest
@testable import TheGoodCorner

@MainActor
final class ListingsRepositoryTests: XCTestCase {
    func testFetchListingsForwardsExpectedRequest() async throws {
        let client = MockAPIClient()
        client.listingsResponse = makeListingsResponse()
        let repository = ListingsRepository(client: client)

        let response = try await repository.fetchListings(page: 2, limit: 50, query: "bike")

        XCTAssertEqual(response.total, 2)
        XCTAssertEqual(client.lastPath, "/listings")
        XCTAssertEqual(client.lastQueryItems, [
            URLQueryItem(name: "page", value: "2"),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "query", value: "bike")
        ])
    }

    func testFetchCategoriesUsesCategoriesEndpoint() async throws {
        let client = MockAPIClient()
        client.categoriesResponse = [Category(id: 1, name: "Vehicule")]
        let repository = ListingsRepository(client: client)

        let categories = try await repository.fetchCategories()

        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(client.lastPath, "/categories")
        XCTAssertNil(client.lastQueryItems)
    }

    private func makeListingsResponse() -> ListingsResponse {
        ListingsResponse(
            total: 2,
            items: [],
            limit: 50,
            hasMore: false,
            page: 2
        )
    }
}
