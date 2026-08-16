import XCTest
@testable import TheGoodCorner

@MainActor
final class ListingsRepositoryTests: XCTestCase {
    func testFetchListingsUsesBaseListingsEndpointWithoutQueryItems() async throws {
        let client = MockAPIClient()
        client.listingsResponse = makeListingsResponse()
        let repository = ListingsRepository(client: client)

        _ = try await repository.fetchListings()

        XCTAssertEqual(client.lastPath, "/listings")
        XCTAssertNil(client.lastQueryItems)
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

    func testSearchListingsUsesListingsEndpointWithQueryItem() async throws {
        let client = MockAPIClient()
        client.listingsResponse = makeListingsResponse()
        let repository = ListingsRepository(client: client)

        _ = try await repository.searchListings(query: "sofa")

        XCTAssertEqual(client.lastPath, "/listings")
        XCTAssertEqual(client.lastQueryItems, [URLQueryItem(name: "query", value: "sofa")])
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
