import Foundation

@MainActor
final class ListingsRepository: ListingsRepositoryProtocol {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchListings(page: Int? = nil, limit: Int? = nil, query: String? = nil) async throws -> ListingsResponse {
        try await client.get(
            ListingsResponse.self,
            from: "/listings",
            queryItems: listingsQueryItems(page: page, limit: limit, query: query)
        )
    }

    func fetchCategories() async throws -> [Category] {
        try await client.get([Category].self, from: "/categories", queryItems: nil)
    }

    private func listingsQueryItems(page: Int?, limit: Int?, query: String?) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let page {
            items.append(URLQueryItem(name: "page", value: String(page)))
        }

        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }

        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "query", value: query))
        }

        return items
    }
}
