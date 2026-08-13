import Foundation

final class ListingsRepository: ListingsRepositoryProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchListings() async throws -> ListingsResponse {
        try await client.get(
            ListingsResponse.self,
            from: "/listings",
            queryItems: []
        )
    }

    func fetchCategories() async throws -> [Category] {
        try await client.get([Category].self, from: "/categories", queryItems: nil)
    }

    func searchListings(query: String) async throws -> ListingsResponse {
        try await client.get(
            ListingsResponse.self,
            from: "/listings",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
    }
}
